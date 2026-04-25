import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'geofence_manager.dart';
import 'screens/home_screen.dart';
import 'screens/radar_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '店家雷達',
      theme: ThemeData(
        fontFamily: 'Inter',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const MainFrame(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainFrame extends StatefulWidget {
  const MainFrame({super.key});
  @override
  State<MainFrame> createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  final GeofenceManager _geo = GeofenceManager();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _geo.onStatusUpdate = () {
      if (mounted) setState(() {});
    };
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.notification,
        Permission.activityRecognition,
      ].request();

      if (statuses[Permission.location]?.isGranted ?? false) {
        await _geo.init();
        await _geo.refreshFences();
        if (mounted) {
          setState(() { _geo.currentStatus = "雷達掃描中..."; });
        }
      } else {
        if (mounted) {
          setState(() { _geo.currentStatus = "請前往手機設定開啟定位權限"; });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() { _geo.currentStatus = "啟動異常"; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 修正：確保 RadarScreen 接收 geo 參數
    final List<Widget> screens = [
      HomeScreen(geo: _geo),
      RadarScreen(geo: _geo),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("當前定位狀態", style: TextStyle(fontSize: 10, color: Colors.indigo, fontWeight: FontWeight.bold)),
            Text(_geo.currentStatus, style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: () => _geo.refreshFences())
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "首頁"),
          BottomNavigationBarItem(icon: Icon(Icons.radar_outlined), label: "雷達"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "會員"),
        ],
      ),
    );
  }
}