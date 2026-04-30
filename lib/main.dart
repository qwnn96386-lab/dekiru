import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'geofence_manager.dart';
import 'screens/home_screen.dart';
import 'screens/radar_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  // 1. 確保引擎初始化
  WidgetsFlutterBinding.ensureInitialized();
  // 2. 立刻啟動 UI，不要在外面 await，防止空白畫面
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const MainFrame(),
    );
  }
}

class MainFrame extends StatefulWidget {
  const MainFrame({super.key});
  @override
  State<MainFrame> createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  final _geo = GeofenceManager();
  int _idx = 0;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _startApp();
  }

  // 將所有初始化移動到 App 內部執行
  Future<void> _startApp() async {
    // 請求權限 (定位、感測器、通知)
    await [
      Permission.location,
      Permission.locationAlways,
      Permission.sensors,
      Permission.notification
    ].request();

    // 初始化雷達
    try {
      await _geo.init();
      _geo.onStatusUpdate = () => setState(() {});
    } catch (e) {
      debugPrint("雷達初始化失敗，但我們繼續運行: $e");
    }

    if (mounted) setState(() => _isReady = true);
  }

  @override
  Widget build(BuildContext context) {
    // 初始化時顯示轉圈圈，而不是空白
    if (!_isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = [
      HomeScreen(geo: _geo),
      RadarScreen(geo: _geo),
      const SettingsScreen()
    ];

    return Scaffold(
      body: pages[_idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: "即時支付"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "個人資訊"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "設定"),
        ],
      ),
    );
  }
}
