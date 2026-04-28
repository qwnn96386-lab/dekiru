import 'dart:async';
import 'dart:math' as math;
import 'package:geofence_service/geofence_service.dart' hide LocationAccuracy;
import 'db_helper.dart';

class GeofenceManager {
  static final GeofenceManager _instance = GeofenceManager._internal();
  factory GeofenceManager() => _instance;
  GeofenceManager._internal();

  final _geofenceService = GeofenceService.instance.setup(
    interval: 5000, accuracy: 100, useActivityRecognition: true, allowMockLocations: false,
  );

  List<Shop> nearbyShops = [];
  Shop? selectedShop;
  double radarRange = 100.0; 
  Function? onStatusUpdate;
  double _lastLat = 0, _lastLng = 0;

  Future<void> init() async {
    _geofenceService.addLocationChangeListener((Location location) async {
      _lastLat = location.latitude; _lastLng = location.longitude;
      await forceScan();
    });
    await _geofenceService.start();
  }

  Future<void> forceScan() async {
    final all = await DBHelper().getShops();
    List<Shop> found = [];
    for (var shop in all) {
      double d = _dist(_lastLat, _lastLng, shop.lat, shop.lng);
      if (d <= radarRange) found.add(shop);
    }
    nearbyShops = found.take(4).toList();
    if (selectedShop == null && nearbyShops.isNotEmpty) selectedShop = nearbyShops.first;
    else if (nearbyShops.isEmpty) selectedShop = null;
    onStatusUpdate?.call();
  }

  double _dist(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 - math.cos((lat2 - lat1) * p) / 2 + math.cos(lat1 * p) * math.cos(lat2 * p) * (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)) * 1000;
  }
}
