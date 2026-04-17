import 'dart:async';
import 'package:geofence_service/geofence_service.dart' hide LocationAccuracy;
import 'package:geolocator/geolocator.dart' hide ActivityType; 
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'db_helper.dart';

class GeofenceManager {
  static final GeofenceManager _instance = GeofenceManager._internal();
  factory GeofenceManager() => _instance;
  GeofenceManager._internal();

  final _dbHelper = DBHelper();
  final _notifications = FlutterLocalNotificationsPlugin();
  final _geofenceService = GeofenceService.instance;

  String currentStatus = "環境感知中...";
  Position? _lastWakeupPos;
  Timer? _sleepTimer;
  Function? onStatusUpdate;

  Future<void> init() async {
    const ios = DarwinInitializationSettings();
    await _notifications.initialize(const InitializationSettings(iOS: ios));

    _geofenceService.setup(
      interval: 5000,
      accuracy: 100,
      loiteringDelayMs: 15000,
      statusChangeDelayMs: 1000,
      useActivityRecognition: true,
    );

    _setupListeners();
  }

  Future<void> refreshFences() async {
    _log("更新 19+1 雷達...");
    Position pos = await Geolocator.getCurrentPosition();
    List<Shop> all = await _dbHelper.getShops();

    all.sort((a, b) => Geolocator.distanceBetween(pos.latitude, pos.longitude, a.lat, a.lng)
        .compareTo(Geolocator.distanceBetween(pos.latitude, pos.longitude, b.lat, b.lng)));

    List<Geofence> fenceList = [];
    
    for (int i = 0; i < all.length && i < 19; i++) {
      fenceList.add(Geofence(
        id: 'SHOP_${all[i].name}',
        latitude: all[i].lat,
        longitude: all[i].lng,
        radius: [GeofenceRadius(id: 'r10', length: 10)],
      ));
    }

    if (all.length >= 20) {
      double r = Geolocator.distanceBetween(pos.latitude, pos.longitude, all[19].lat, all[19].lng);
      fenceList.add(Geofence(
        id: 'MOTHER_FENCE',
        latitude: pos.latitude,
        longitude: pos.longitude,
        radius: [GeofenceRadius(id: 'm_radius', length: r)],
      ));
    }

    _geofenceService.stop();
    _geofenceService.start(fenceList).catchError((e) => print(e));
    _log("雷達已更新 (半徑 10m)");
  }

  void _setupListeners() {
    _geofenceService.addActivityChangeListener((Activity activity) {
      _onActivityChanged(activity);
    } as ActivityChanged);

    _geofenceService.addGeofenceStatusChangeListener((
      Geofence geofence, 
      GeofenceRadius geofenceRadius, 
      GeofenceStatus geofenceStatus, 
      Location location
    ) {
      _onGeofenceStatusChanged(geofence, geofenceRadius, geofenceStatus, location);
    } as GeofenceStatusChanged);
  }

  // 修改處：使用 STILL 與 IN_VEHICLE
  Future<void> _onActivityChanged(Activity activity) async {
    if (activity.type == ActivityType.STILL) {
      _sleepTimer?.cancel();
      _sleepTimer = Timer(const Duration(minutes: 3), () {
        _geofenceService.stop();
        _log("智慧休眠中 (靜止 > 3min)");
      });
    } else if (activity.type == ActivityType.WALKING) {
      _sleepTimer?.cancel();
      Position now = await Geolocator.getCurrentPosition();
      
      double dist = (_lastWakeupPos == null) ? 999 : 
          Geolocator.distanceBetween(_lastWakeupPos!.latitude, _lastWakeupPos!.longitude, now.latitude, now.longitude);

      if (dist > 10) { 
        _lastWakeupPos = now;
        await refreshFences();
        _log("偵測走路且移動 > 10m");
      }
    } else if (activity.type == ActivityType.IN_VEHICLE) {
      _geofenceService.stop();
      _log("高速移動中：暫停雷達");
    }
  }

  Future<void> _onGeofenceStatusChanged(
    Geofence geofence, 
    GeofenceRadius geofenceRadius, 
    GeofenceStatus geofenceStatus, 
    Location location
  ) async {
    if (geofence.id == 'MOTHER_FENCE' && geofenceStatus == GeofenceStatus.EXIT) {
      await refreshFences();
      return;
    }

    if (geofenceStatus == GeofenceStatus.DWELL) {
      Position p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      double checkDist = Geolocator.distanceBetween(p.latitude, p.longitude, geofence.latitude, geofence.longitude);
      
      if (checkDist <= 15) {
        _sendNotify(geofence.id.replaceAll('SHOP_', ''));
      }
    }
  }

  void _sendNotify(String name) async {
    const ios = DarwinNotificationDetails(presentAlert: true, presentSound: true);
    await _notifications.show(0, "進入 $name", "享回饋！", const NotificationDetails(iOS: ios));
  }

  void _log(String msg) {
    currentStatus = msg;
    if (onStatusUpdate != null) onStatusUpdate!();
    print(msg);
  }
}