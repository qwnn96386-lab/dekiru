import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MaterialApp(
    home: PermissionScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  String _statusText = "尚未檢測";
  Color _statusColor = Colors.grey;

  Future<void> checkAndRequestPermissions() async {
    // 1. 同時請求通知與定位權限
    Map<Permission, PermissionStatus> statuses = await [
      Permission.notification,
      Permission.locationWhenInUse,
    ].request();

    // 2. 取得各自的狀態
    final notificationStatus = statuses[Permission.notification];
    final locationStatus = statuses[Permission.locationWhenInUse];

    // 3. 判斷邏輯：兩者都必須是 granted 才是成功
    if (notificationStatus == PermissionStatus.granted && 
        locationStatus == PermissionStatus.granted) {
      setState(() {
        _statusText = "成功";
        _statusColor = Colors.green;
      });
    } else {
      setState(() {
        _statusText = "失敗";
        _statusColor = Colors.red;
      });
      
      // 如果使用者永久拒絕，可以引導去設定頁面
      if (notificationStatus == PermissionStatus.permanentlyDenied || 
          locationStatus == PermissionStatus.permanentlyDenied) {
        print("使用者已永久拒絕，請前往設定開啟");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("權限授權檢測")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("權限狀態：", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(
              _statusText,
              style: TextStyle(
                fontSize: 48, 
                fontWeight: FontWeight.bold, 
                color: _statusColor
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
              onPressed: checkAndRequestPermissions,
              child: const Text("開始授權流程"),
            ),
          ],
        ),
      ),
    );
  }
}