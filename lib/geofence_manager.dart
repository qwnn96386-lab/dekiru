import 'dart:async';
import 'dart:math' as math;
import 'package:geofence_service/geofence_service.dart' hide LocationAccuracy;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'db_helper.dart';

class GeofenceManager {
  static final GeofenceManager _instance = GeofenceManager._internal();
  factory GeofenceManager() => _instance;
  GeofenceManager._internal();

  final _geofenceService = GeofenceService.instance.setup(
    interval: 5000,
    accuracy: 100,
    useActivityRecognition: true,
    allowMockLocations: false,
    printDevLog: false,
  );

  final _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  String currentStatus = "雷達系統待命";
  
  Shop? _nearestShop; 
  Shop? get nearestShop => _nearestShop; 
  
  double radarRange = 100.0;
  Function? onStatusUpdate;

  // 定位監控中的座標
  double? _lastLat;
  double? _lastLng;

  Future<void> init() async {
    // 綁定定位更新
    _geofenceService.addLocationChangeListener((Location location) async {
      _lastLat = location.latitude;
      _lastLng = location.longitude;
      currentStatus = "經度: ${location.longitude.toStringAsFixed(6)}, 緯度: ${location.latitude.toStringAsFixed(6)}";
      
      await _updateNearestShop(_lastLat!, _lastLng!);
      onStatusUpdate?.call(); // 通知 UI 更新
    });
    
    // 啟動服務
    await _geofenceService.start();
  }

  // --- 修復：新增 refreshFences 方法 ---
  Future<void> refreshFences() async {
    if (_lastLat != null && _lastLng != null) {
      await _updateNearestShop(_lastLat!, _lastLng!);
    } else {
      // 若尚未有座標，僅更新店家列表（這裡可視需求擴充）
      currentStatus = "尋找衛星定位中...";
    }
    onStatusUpdate?.call();
  }

  Future<void> _updateNearestShop(double userLat, double userLng) async {
    final shops = await DBHelper().getShops();
    if (shops.isEmpty) { 
      _nearestShop = null; 
      return; 
    }

    Shop? closest;
    double minDistance = double.infinity;

    for (var shop in shops) {
      double d = _calculateDistance(userLat, userLng, shop.lat, shop.lng);
      if (d < minDistance) { 
        minDistance = d; 
        closest = shop; 
      }
    }

    // 若最近店家在雷達範圍內則顯示，否則設為 null
    _nearestShop = (minDistance <= radarRange) ? closest : null;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 - math.cos((lat2 - lat1) * p) / 2 +
              math.cos(lat1 * p) * math.cos(lat2 * p) *
              (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)) * 1000;
  }
}