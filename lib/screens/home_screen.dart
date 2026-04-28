import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:url_launcher/url_launcher.dart';
import '../geofence_manager.dart';
import '../db_helper.dart';

class HomeScreen extends StatefulWidget {
  final GeofenceManager geo;
  const HomeScreen({super.key, required this.geo});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isExp = false;
  String _carrier = "";
  List<PaymentApp> _pays = [];

  @override
  void initState() {
    super.initState();
    _load();
    accelerometerEvents.listen((e) {
      if (!mounted) return;
      if (e.y > 7.5 && !_isExp) _toggle(true);
      else if (e.y < 3.0 && _isExp) _toggle(false);
    });
    PerfectVolumeControl.stream.listen((v) => _handleVolumeKey());
  }

  _load() async {
    _carrier = await DBHelper().getCarrier();
    _pays = await DBHelper().getPayments();
    setState(() {});
  }

  void _toggle(bool exp) async {
    setState(() => _isExp = exp);
    if (exp) await ScreenBrightness().setScreenBrightness(1.0);
    else await ScreenBrightness().resetScreenBrightness();
  }

  void _handleVolumeKey() {
    if (_pays.isEmpty) return;
    final s = widget.geo.selectedShop;
    if (s != null && s.isSpecial) _showChoice();
    else _launchPay(_pays.first.name);
  }

  void _showChoice() {
    showModalBottomSheet(context: context, builder: (c) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const ListTile(title: Text("請選擇支付方案", style: TextStyle(fontWeight: FontWeight.bold))),
      ListTile(leading: const Icon(Icons.star, color: Colors.red), title: const Text("方案 A：特別滿減回饋"), onTap: () { Navigator.pop(c); _launchPay(_pays.first.name); }),
      ListTile(leading: const Icon(Icons.percent, color: Colors.blue), title: const Text("方案 B：常態支付回饋"), onTap: () { Navigator.pop(c); _launchPay(_pays.first.name); }),
    ])));
  }

  void _launchPay(String name) async {
    String url = name.contains("街口") ? "jkos://" : "linepay://";
    if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.geo.selectedShop;
    return Stack(children: [
      Column(children: [
        const SizedBox(height: 60),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: widget.geo.nearbyShops.map((i) => _circle(i)).toList()),
        const SizedBox(height: 30),
        if (s != null) _card(s) else const Expanded(child: Center(child: Text("雷達掃描中..."))),
      ]),
      _barcode(s), // 底部細長條
    ]);
  }

  Widget _circle(Shop s) {
    bool active = widget.geo.selectedShop?.id == s.id;
    return GestureDetector(
      onTap: () => setState(() => widget.geo.selectedShop = s),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: active ? Colors.blue : Colors.transparent, width: 2)),
        child: Stack(children: [
          CircleAvatar(radius: 25, backgroundColor: Colors.grey[100], child: Text(s.name[0])),
          if (s.isSpecial) Positioned(right: 0, top: 0, child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
        ]),
      ),
    );
  }

  Widget _card(Shop s) => Container(
    margin: const EdgeInsets.all(25), padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: s.isSpecial ? Colors.red : Colors.blue, width: 2.5), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(s.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const Divider(height: 30),
      _row("最優支付", _pays.isNotEmpty ? "${_pays.first.reward}%" : "無資料"),
      if (s.isSpecial) ...[const Divider(), _row("滿減回饋", s.specialRule, isRed: true)],
    ]),
  );

  Widget _row(String n, String r, {bool isRed = false}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(n), Text(r, style: TextStyle(fontSize: isRed ? 18 : 26, fontWeight: FontWeight.bold, color: isRed ? Colors.red : Colors.blue))]);

  Widget _barcode(Shop? s) => AnimatedPositioned(
    duration: const Duration(milliseconds: 300), bottom: 0, left: 0, right: 0, height: _isExp ? 420 : 40,
    child: GestureDetector(
      onTap: () => _toggle(!_isExp),
      child: Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: _isExp ? Column(children: [
          const SizedBox(height: 10), Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 25), const Text("手機載具"), BarcodeWidget(barcode: Barcode.code39(), data: _carrier, width: 260, height: 75),
          const SizedBox(height: 35), Text("${s?.name ?? ''} 會員碼"), BarcodeWidget(barcode: Barcode.code128(), data: s?.barcode ?? "", width: 260, height: 75),
        ]) : Center(child: Container(width: 60, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
      ),
    ),
  );
}
