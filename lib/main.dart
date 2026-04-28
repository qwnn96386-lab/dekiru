import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'geofence_manager.dart';
import 'screens/home_screen.dart';
import 'screens/radar_screen.dart';
import 'screens/settings_screen.dart';
void main() async {
WidgetsFlutterBinding.ensureInitialized();
await [Permission.location, Permission.locationAlways, Permission.sensors].request();
await GeofenceManager().init();
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
@override
void initState() {
super.initState();
_geo.onStatusUpdate = () => setState(() {});
}
@override
Widget build(BuildContext context) {
final pages = [HomeScreen(geo: _geo), RadarScreen(geo: _geo), const SettingsScreen()];
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
