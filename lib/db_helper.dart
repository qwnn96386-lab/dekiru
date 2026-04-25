import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Shop {
  final int? id;
  final String name;
  final double lat;
  final double lng;
  final String icon;       // 新增：🏪 
  final String barcode;    // 新增：會員條碼或載具
  final String payments;   // 新增：以逗號隔開的支付方式 (例如 "街口,LinePay")
  final String offers;     // 新增：特惠資訊

  Shop({
    this.id, 
    required this.name, 
    required this.lat, 
    required this.lng,
    this.icon = "🏪",
    this.barcode = "",
    this.payments = "",
    this.offers = "",
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'icon': icon,
      'barcode': barcode,
      'payments': payments,
      'offers': offers,
    };
  }

  factory Shop.fromMap(Map<String, dynamic> map) {
    return Shop(
      id: map['id'] as int?,
      name: map['name'] as String,
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      icon: map['icon'] ?? "🏪",
      barcode: map['barcode'] ?? "",
      payments: map['payments'] ?? "",
      offers: map['offers'] ?? "",
    );
  }
}

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();
  static Database? _db;

  Future<Database> get db async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'shops_radar_v2.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
        "CREATE TABLE shops(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, lat REAL, lng REAL, icon TEXT, barcode TEXT, payments TEXT, offers TEXT)"
      );
    });
  }

  Future<int> insertShop(Shop shop) async => (await db).insert('shops', shop.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  Future<List<Shop>> getShops() async => (await (await db).query('shops', orderBy: 'id DESC')).map((m) => Shop.fromMap(m)).toList();
  Future<int> deleteShop(int id) async => (await db).delete('shops', where: 'id = ?', whereArgs: [id]);
}