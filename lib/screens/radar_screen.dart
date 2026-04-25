import 'package:flutter/material.dart';
import '../geofence_manager.dart';

class RadarScreen extends StatelessWidget {
  final GeofenceManager geo;
  const RadarScreen({super.key, required this.geo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text("偵測範圍內店家", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const Divider(indent: 50, endIndent: 50),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.radar, size: 100, color: Colors.indigo.withOpacity(0.2)),
                const SizedBox(height: 20),
                const Text("目前掃描半徑：100m", style: TextStyle(color: Colors.grey)),
                if (geo.nearestShop == null) 
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text("尚未發現店家，請移動位置...", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text("雷達將自動掃描並提示周邊支援之店家", style: TextStyle(color: Colors.grey, fontSize: 11)),
        ),
      ],
    );
  }
}