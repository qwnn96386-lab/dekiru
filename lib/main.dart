import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// 引用你分擔出去的模組
import 'db_helper.dart';
import 'geofence_manager.dart';

void main() async {
  // 確保 Flutter 套件與原生端橋接已初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化地理圍欄引擎 (這會啟動通知與行為辨識監聽)
  await GeofenceManager().init();
  
  runApp(const MaterialApp(
    home: MainListScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

// ==========================================
// 第一級介面：清單瀏覽與狀態顯示
// ==========================================
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
    // 當 GeofenceManager 狀態改變時，通知此頁面更新畫面 (如 AppBar 的狀態文字)
    _geo.onStatusUpdate = () {
      if (mounted) setState(() {});
    };
    
    _initSystem();
  }

  // 請求權限並載入初步資料
  Future<void> _initSystem() async {
    // 請求核心權限：定位(始終允許)、行為傳感器、通知
    await [
      Permission.locationAlways,
      Permission.sensors,
      Permission.notification
    ].request();
    
    _refreshData();
  }

  // 從資料庫重新載入清單，並要求雷達重新掃描
  Future<void> _refreshData() async {
    final list = await _db.getShops();
    setState(() {
      _shops = list;
    });
    
    // 資料變動後，要求 19+1 雷達更新監控點位
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
              _geo.currentStatus, // 顯示 GeofenceManager 傳回的狀態
              style: const TextStyle(color: Colors.greenAccent, fontSize: 10),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.white),
            onPressed: () async {
              // 進入二級介面
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const AddShopScreen()),
              );
              // 回來後刷新清單與雷達
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

// ==========================================
// 第二級介面：資料輸入頁面
// ==========================================
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
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "店家名稱",
                hintText: "例如：7-11 某某門市",
                prefixIcon: Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _latController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "緯度 (Latitude)",
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lngController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "經度 (Longitude)",
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  // 簡單驗證
                  if (_nameController.text.isEmpty ||
                      _latController.text.isEmpty ||
                      _lngController.text.isEmpty) {
                    return;
                  }

                  // 儲存至資料庫
                  await DBHelper().insertShop(Shop(
                    name: _nameController.text,
                    lat: double.parse(_latController.text),
                    lng: double.parse(_lngController.text),
                  ));

                  // 返回上一頁
                  if (mounted) Navigator.pop(context);
                },
                child: const Text("儲存並啟動監控", style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}