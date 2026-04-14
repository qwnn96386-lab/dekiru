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

    final notificationStatus = statuses[Permission.notification];
    final locationStatus = statuses[Permission.locationWhenInUse];

    // 2. 判斷邏輯
    if (notificationStatus == PermissionStatus.granted && 
        locationStatus == PermissionStatus.granted) {
      setState(() {
        _statusText = "全部授權成功";
        _statusColor = Colors.green;
      });
    } else {
      setState(() {
        _statusText = "授權失敗";
        _statusColor = Colors.red;
      });
      
      // 3. 處理「永久拒絕」的情況 (使用者點過兩次拒絕，或是之前選過不允許)
      if (notificationStatus == PermissionStatus.permanentlyDenied || 
          locationStatus == PermissionStatus.permanentlyDenied) {
        _showOpenSettingsDialog();
      }
    }
  }

  // 彈出對話框引導使用者去系統設定
  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("需要權限"),
        content: const Text("您已拒絕相關權限，請前往「設定」手動開啟，否則無法使用此功能。"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () {
              openAppSettings(); // 開啟手機系統設定頁面
              Navigator.pop(context);
            },
            child: const Text("去開啟"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("權限授權檢測")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("目前狀態：", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(
              _statusText,
              style: TextStyle(
                fontSize: 32, 
                fontWeight: FontWeight.bold, 
                color: _statusColor
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: checkAndRequestPermissions,
              child: const Text("授權通知與定位", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}