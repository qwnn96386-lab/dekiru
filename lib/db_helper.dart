import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Shop {
  final int? id;
  final String name, barcode, specialRule;
  final double lat, lng;
  final bool isSpecial;
  Shop({this.id, required this.name, required this.lat, required this.lng, this.barcode = "", this.isSpecial = false, this.specialRule = ""});
  Map<String, dynamic> toMap() => { if (id != null) 'id': id, 'name': name, 'lat': lat, 'lng': lng, 'barcode': barcode, 'isSpecial': isSpecial ? 1 : 0, 'specialRule': specialRule };
  factory Shop.fromMap(Map<String, dynamic> m) => Shop(id: m['id'] as int?, name: m['name'] as String, lat: (m['lat'] as num).toDouble(), lng: (m['lng'] as num).toDouble(), barcode: m['barcode'] ?? "", isSpecial: m['isSpecial'] == 1, specialRule: m['specialRule'] ?? "");
}

class PaymentApp {
  final int? id;
  final String name;
  final double reward;
  PaymentApp({this.id, required this.name, required this.reward});
  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'reward': reward};
  factory PaymentApp.fromMap(Map<String, dynamic> m) => PaymentApp(id: m['id'] as int, name: m['name'] as String, reward: (m['reward'] as num).toDouble());
}

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();
  static Database? _db;
  Future<Database> get db async { _db ??= await _init(); return _db!; }
  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'shop_radar_final_v1.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute("CREATE TABLE shops(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, lat REAL, lng REAL, barcode TEXT, isSpecial INTEGER, specialRule TEXT)");
      await db.execute("CREATE TABLE carrier(id INTEGER PRIMARY KEY, code TEXT)");
      await db.execute("CREATE TABLE payments(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, reward REAL)");
      await db.insert('carrier', {'id': 1, 'code': ''});
    });
  }
  Future<String> getCarrier() async => (await (await db).query('carrier')).first['code'] as String;
  Future<void> updateCarrier(String code) async => (await db).update('carrier', {'code': code}, where: 'id = 1');
  Future<List<PaymentApp>> getPayments() async => (await (await db).query('payments')).map((m) => PaymentApp.fromMap(m)).toList();
  Future<void> addPayment(PaymentApp p) async => (await db).insert('payments', p.toMap());
  Future<void> deletePayment(int id) async => (await db).delete('payments', where: 'id = ?', whereArgs: [id]);
  Future<List<Shop>> getShops() async => (await (await db).query('shops')).map((m) => Shop.fromMap(m)).toList();
  Future<void> insertShop(Shop s) async => (await db).insert('shops', s.toMap());
  Future<void> deleteShop(int id) async => (await db).delete('shops', where: 'id = ?', whereArgs: [id]);
}
