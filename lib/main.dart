import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// 請確保你有這兩個檔案
import 'db_helper.dart'; 
import 'geofence_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化地理圍欄
  await GeofenceManager().init();
  
  runApp(const MaterialApp(
    home: MainListScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class MainListScreen extends StatefulWidget {
  const MainListScreen({super.key});
  @override
  State<MainListScreen> createState() => _MainListScreenState();
}

class _MainListScreenState extends State<MainListScreen> {
  final _db = DBHelper();
  final _geo = GeofenceManager();
  List<Shop> _shops = [];

  @override
  void initState() {
    super.initState();
    _geo.onStatusUpdate = () {
      if (mounted) setState(() {});
    };
    _initSystem();
  }

  Future<void> _initSystem() async {
    // 請求權限
    Map<Permission, PermissionStatus> statuses = await [
      Permission.locationWhenInUse,
      Permission.locationAlways,
      Permission.sensors,
      Permission.notification
    ].request();

    if (statuses[Permission.locationAlways]!.isGranted) {
       _refreshData();
    } else {
       // 如果沒給權限，可以在這裡跳出提示
       print("需要背景定位權限才能運作");
    }
  }

  Future<void> _refreshData() async {
    final list = await _db.getShops();
    setState(() {
      _shops = list;
    });
    await _geo.refreshFences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("店家監控雷達", style: TextStyle(color: Colors.white, fontSize: 18)),
            Text(
              _geo.currentStatus,
              style: const TextStyle(color: Colors.greenAccent, fontSize: 10),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const AddShopScreen()),
              );
              _refreshData();
            },
          )
        ],
      ),
      body: _shops.isEmpty
          ? const Center(child: Text("目前沒有店家，請點擊右上角新增"))
          : ListView.builder(
              itemCount: _shops.length,
              itemBuilder: (c, i) => ListTile(
                leading: const Icon(Icons.store, color: Colors.indigo),
                title: Text(_shops[i].name),
                subtitle: Text("緯度: ${_shops[i].lat}, 經度: ${_shops[i].lng}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    if (_shops[i].id != null) {
                      await _db.deleteShop(_shops[i].id!);
                      _refreshData();
                    }
                  },
                ),
              ),
            ),
    );
  }
}

// 二級介面：新增店家
class AddShopScreen extends StatefulWidget {
  const AddShopScreen({super.key});
  @override
  State<AddShopScreen> createState() => _AddShopScreenState();
}

class _AddShopScreenState extends State<AddShopScreen> {
  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("新增店家資料")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "店家名稱", prefixIcon: Icon(Icons.edit))),
            const SizedBox(height: 16),
            TextField(controller: _latController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "緯度", prefixIcon: Icon(Icons.location_on))),
            const SizedBox(height: 16),
            TextField(controller: _lngController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "經度", prefixIcon: Icon(Icons.location_on))),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                onPressed: () async {
                  if (_nameController.text.isEmpty) return;
                  await DBHelper().insertShop(Shop(
                    name: _nameController.text,
                    lat: double.parse(_latController.text),
                    lng: double.parse(_lngController.text),
                  ));
                  if (mounted) Navigator.pop(context);
                },
                child: const Text("儲存並啟動監控"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}