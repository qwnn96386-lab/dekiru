import 'package:flutter/material.dart';
import '../db_helper.dart';
import '../geofence_manager.dart';

class RadarScreen extends StatefulWidget {
  final GeofenceManager geo;
  const RadarScreen({super.key, required this.geo});
  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  final _carrierCtrl = TextEditingController();
  List<Shop> _shops = [];
  List<PaymentApp> _pays = [];

  @override
  void initState() { super.initState(); _load(); }

  _load() async {
    _carrierCtrl.text = await DBHelper().getCarrier();
    _shops = await DBHelper().getShops();
    _pays = await DBHelper().getPayments();
    if (mounted) setState(() {});
    widget.geo.forceScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("狀態：${widget.geo.selectedShop?.name ?? '偵測中'}", style: const TextStyle(fontSize: 13)),
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline, size: 28), onPressed: () => _navAdd()),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _title("載具管理 (唯一)"),
          TextField(controller: _carrierCtrl, decoration: const InputDecoration(hintText: "載具號碼"), onSubmitted: (v) => DBHelper().updateCarrier(v)),
          const SizedBox(height: 20),
          _title("支付管理"),
          ..._pays.map((p) => ListTile(title: Text(p.name), subtitle: Text("${p.reward}%"), trailing: IconButton(icon: const Icon(Icons.close), onPressed: () async { await DBHelper().deletePayment(p.id!); _load(); }))),
          TextButton.icon(onPressed: _showAddPay, icon: const Icon(Icons.add), label: const Text("連動新增支付")),
          const Divider(height: 40),
          _title("會員與圍欄管理 (1, 2, 3...)"),
          Row(children: [const Text("半徑 "), Expanded(child: Slider(value: widget.geo.radarRange, min: 10, max: 200, onChanged: (v) { setState(() => widget.geo.radarRange = v); widget.geo.forceScan(); })), Text("${widget.geo.radarRange.round()}m")]),
          ..._shops.asMap().entries.map((e) => Card(child: ListTile(
            leading: CircleAvatar(child: Text("${e.key + 1}")),
            title: Text(e.value.name),
            trailing: IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () async { await DBHelper().deleteShop(e.value.id!); _load(); }),
          ))),
          const SizedBox(height: 10),
          OutlinedButton.icon(onPressed: _navAdd, icon: const Icon(Icons.add), label: const Text("新增店家資訊")),
        ],
      ),
    );
  }

  void _showAddPay() {
    String sel = "街口支付"; double rew = 3.0;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("新增支付"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(
          value: sel, items: ["街口支付", "Line Pay", "自定義"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() { sel = v!; rew = (v == "街口支付") ? 3.0 : 2.0; }),
        ),
        TextField(decoration: const InputDecoration(labelText: "回饋 %"), keyboardType: TextInputType.number, onChanged: (v) => rew = double.tryParse(v) ?? 0),
      ]),
      actions: [TextButton(onPressed: () async { await DBHelper().addPayment(PaymentApp(name: sel, reward: rew)); Navigator.pop(ctx); _load(); }, child: const Text("儲存"))],
    ));
  }

  _navAdd() async { await Navigator.push(context, MaterialPageRoute(builder: (c) => const AddShopScreen())); _load(); }
  Widget _title(String t) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)));
}

class AddShopScreen extends StatelessWidget {
  const AddShopScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final n = TextEditingController(), la = TextEditingController(), lo = TextEditingController(), bar = TextEditingController(), rule = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text("新增店家")),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        TextField(controller: n, decoration: const InputDecoration(labelText: "店名")),
        Row(children: [
          Expanded(child: TextField(controller: la, decoration: const InputDecoration(labelText: "緯度"), keyboardType: TextInputType.number)),
          const SizedBox(width: 10),
          Expanded(child: TextField(controller: lo, decoration: const InputDecoration(labelText: "經度"), keyboardType: TextInputType.number)),
        ]),
        TextField(controller: bar, decoration: const InputDecoration(labelText: "會員碼")),
        TextField(controller: rule, decoration: const InputDecoration(labelText: "加碼方案")),
        const Spacer(),
        SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () async {
          double? lat = double.tryParse(la.text); double? lng = double.tryParse(lo.text);
          if (lat != null && lng != null) {
            await DBHelper().insertShop(Shop(name: n.text, lat: lat, lng: lng, barcode: bar.text, isSpecial: rule.text.isNotEmpty, specialRule: rule.text));
            Navigator.pop(context);
          }
        }, child: const Text("完成儲存"))),
      ])),
    );
  }
}
