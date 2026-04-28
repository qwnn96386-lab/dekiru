import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("設定")),
      body: ListView(
        children: [
          const ListTile(leading: Icon(Icons.info_outline), title: Text("關於店家雷達"), subtitle: Text("版本 1.0.0")),
          const Divider(),
          ListTile(leading: const Icon(Icons.location_on_outlined), title: const Text("權限檢查"), onTap: () {}),
          ListTile(leading: const Icon(Icons.notifications_none), title: const Text("通知設定"), onTap: () {}),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("重設所有資料", style: TextStyle(color: Colors.red)),
            onTap: () => _showReset(context),
          ),
        ],
      ),
    );
  }

  void _showReset(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("警告"),
      content: const Text("這將刪除所有已儲存的店家與支付資料。"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("取消")),
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("確定重設", style: TextStyle(color: Colors.red))),
      ],
    ));
  }
}
