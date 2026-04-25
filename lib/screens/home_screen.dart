import 'package:flutter/material.dart';
import '../geofence_manager.dart';
import '../db_helper.dart';

class HomeScreen extends StatelessWidget {
  final GeofenceManager geo;
  const HomeScreen({super.key, required this.geo});

  @override
  Widget build(BuildContext context) {
    final shop = geo.nearestShop;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 頂端圓圈狀態 (圖稿上方)
          const Row(
            children: [
              CircleAvatar(radius: 30, backgroundColor: Colors.indigo),
              SizedBox(width: 20),
              CircleAvatar(radius: 40, backgroundColor: Colors.blueAccent),
            ],
          ),
          const SizedBox(height: 20),

          // 店家主卡片 (藍色框)
          if (shop != null) Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.blue.shade600, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text(shop.icon, style: const TextStyle(fontSize: 30))),
                    ),
                    const SizedBox(width: 15),
                    Text(shop.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                // 行動支付圖示列
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: shop.payments.split(',').map((p) => _PaymentIcon(label: p)).toList(),
                ),
                const SizedBox(height: 20),
                const Text("會員條碼 / 載具", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 10),
                // 條碼
                Container(
                  height: 60, width: double.infinity,
                  color: Colors.grey.shade50,
                  child: Center(child: Text(shop.barcode, style: const TextStyle(letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 18))),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          // 優惠資訊 (綠色框)
          if (shop != null) Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.green.shade300, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("店家特典優惠資訊", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...shop.offers.split(',').map((o) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text("• $o", style: const TextStyle(color: Colors.black87)),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _PaymentIcon extends StatelessWidget {
  final String label;
  const _PaymentIcon({required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 45, height: 45,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
          child: const Center(child: Text("行支", style: TextStyle(fontSize: 10, color: Colors.grey))),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}