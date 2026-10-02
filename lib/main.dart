import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SaikrupaApp());
}

class SaikrupaApp extends StatelessWidget {
  const SaikrupaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  String filterBatch = "सगळे";
  List<Map<String, dynamic>> students = [];
  final months = ["जून","जुलै","ऑगस्ट","सप्टेंबर","ऑक्टोबर","नोव्हेंबर","डिसेंबर","जानेवारी","फेब्रुवारी","मार्च","एप्रिल","मे"];
  final defaultStudents = [
    {"name": "विहान लुपे", "fee": 360, "batch": "सकाळ", "payments": {}},
    {"name": "क्रिशा किरमे", "fee": 400, "batch": "सकाळ", "payments": {}},
    {"name": "तेजल पाटील", "fee": 550, "batch": "संध्याकाळ", "payments": {}},
    {"name": "पूर्वा पाटील", "fee": 550, "batch": "संध्याकाळ", "payments": {}},
  ];

  @override
  void initState() { super.initState(); loadData(); }
  Future<void> loadData() async {
    final p = await SharedPreferences.getInstance();
    final d = p.getString('sc_v12');
    if (d!= null) { setState(() { students = List<Map<String, dynamic>>.from(jsonDecode(d)); }); }
    else { setState(() { students = List<Map<String, dynamic>>.from(defaultStudents); }); }
  }
  Future<void> saveData() async { final p = await SharedPreferences.getInstance(); p.setString('sc_v12', jsonEncode(students)); }
  Widget logoWidget(double size) {
    return ClipOval(child: Image.asset('assets/images/logo.png', width: size, height: size, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(width: size, height: size, decoration: const BoxDecoration(color: Color(0xFF0A2351), shape: BoxShape.circle), child: const Center(child: Text("SC", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))))));
  }
  void showAddEditDialog({Map<String, dynamic>? editData, int? editIndex}) {
    TextEditingController nameC = TextEditingController(text: editData!= null? editData['name'] : "");
    TextEditingController feeC = TextEditingController(text: editData!= null? editData['fee'].toString() : "400");
    String batch = editData!= null? editData['batch'] : "सकाळ";
    showDialog(context: context, builder: (context) {
      return StatefulBuilder(builder: (context, setD) {
        return AlertDialog(
          title: Text(editData == null? "नवीन विद्यार्थी" : "एडिट करा"),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameC, decoration: const InputDecoration(labelText: "नाव", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: feeC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "फी", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(value: batch, decoration: const InputDecoration(labelText: "बॅच", border: OutlineInputBorder()), items: const [DropdownMenuItem(value: "सकाळ", child: Text("सकाळ")), DropdownMenuItem(value: "संध्याकाळ", child: Text("संध्याकाळ"))], onChanged: (v) { if (v!= null) setD(() => batch = v); }),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("रद्द")),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2351), foregroundColor: Colors.white), onPressed: () { if(nameC.text.trim().isEmpty) return; setState(() { var newData = {"name": nameC.text.trim(), "fee": int.tryParse(feeC.text)?? 400, "batch": batch, "payments": editData!= null? editData['payments'] : {}}; if(editIndex!= null) { students[editIndex] = newData; } else { students.add(newData); } }); saveData(); Navigator.pop(context); }, child: Text(editIndex!= null? "अपडेट" : "जोडा")),
          ],
        );
      });
    });
  }
  void showOptions(int realIndex) {
    var s = students[realIndex];
    showModalBottomSheet(context: context, builder: (c) => Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [ListTile(leading: logoWidget(40), title: Text(s['name'])), const Divider(), ListTile(leading: const Icon(Icons.edit, color: Colors.blue), title: const Text("एडिट करा"), onTap: () { Navigator.pop(c); showAddEditDialog(editData: s, editIndex: realIndex); }), ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text("काढून टाका"), onTap: () { Navigator.pop(c); setState(() => students.removeAt(realIndex)); saveData(); })])));
  }
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered = filterBatch == "सगळे"? students : students.where((s) => s['batch'] == filterBatch).toList();
    return Scaffold(
      appBar: AppBar(title: Row(children: [logoWidget(36), const SizedBox(width: 8), const Text("SAIKRUPA CLASSES", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))]), backgroundColor: const Color(0xFF0A2351), foregroundColor: Colors.white),
      floatingActionButton: tab == 0? FloatingActionButton.extended(onPressed: () => showAddEditDialog(), backgroundColor: const Color(0xFF0A2351), foregroundColor: Colors.amber, icon: const Icon(Icons.person_add), label: const Text("नवीन")) : null,
      bottomNavigationBar: BottomNavigationBar(currentIndex: tab, onTap: (i) => setState(() => tab = i), selectedItemColor: const Color(0xFF0A2351), items: const [BottomNavigationBarItem(icon: Icon(Icons.groups), label: "विद्यार्थी"), BottomNavigationBarItem(icon: Icon(Icons.person), label: "प्रोफाइल")]),
      body: Column(children: [Container(color: Colors.amber.shade50, padding: const EdgeInsets.all(10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("एकूण: ${filtered.length}"), ToggleButtons(isSelected: [filterBatch == "सगळे", filterBatch == "सकाळ", filterBatch == "संध्याकाळ"], onPressed: (i) => setState(() => filterBatch = ["सगळे", "सकाळ", "संध्याकाळ"][i]), children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("सगळे")), Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("सकाळ")), Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("संध्या"))])])), Expanded(child: ListView.builder(itemCount: filtered.length, itemBuilder: (c, i) { var s = filtered[i]; int realIndex = students.indexOf(s); int paid = (s['payments'] as Map).length; return Card(margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), child: ListTile(onLongPress: () => showOptions(realIndex), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(student: s, months: months, logoBuilder: logoWidget, onUpdate: (np) { setState(() => students[realIndex]['payments'] = np); saveData(); }))), leading: logoWidget(40), title: Text(s['name'], style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text("${s['batch']} | ₹${s['fee']} | $paid/12"), trailing: Icon(paid == 12? Icons.verified : Icons.arrow_forward_ios, size: 14, color: paid == 12? Colors.green : Colors.grey))); }))]),
    );
  }
}
class DetailPage extends StatefulWidget { final Map<String, dynamic> student; final List<String> months; final Function(Map) onUpdate; final Widget Function(double) logoBuilder; const DetailPage({super.key, required this.student, required this.months, required this.onUpdate, required this.logoBuilder}); @override State<DetailPage> createState() => _DetailPageState(); }
class _DetailPageState extends State<DetailPage> {
  late Map payments; final ScreenshotController sc = ScreenshotController(); String lastMonth = "";
  @override void initState() { super.initState(); payments = Map.from(widget.student['payments']?? {}); }
  Future<void> shareReceipt(String month) async { setState(() => lastMonth = month); await Future.delayed(const Duration(milliseconds: 600)); final bytes = await sc.capture(); if(bytes == null) return; final dir = await getTemporaryDirectory(); final file = await File('${dir.path}/receipt.png').create(); await file.writeAsBytes(bytes); await Share.shareXFiles([XFile(file.path)], text: "${widget.student['name']} - $month Receipt"); }
  Widget receiptWidget(String month) { return Container(width: 600, color: Colors.white, padding: const EdgeInsets.all(16), child: Column(children: [widget.logoBuilder(100), const SizedBox(height: 8), const Text('SAIKRUPA CLASSES', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0A2351))), const Text('॥ श्री साईनाथाय नमः ॥', style: TextStyle(fontSize: 11, color: Colors.orange)), Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8), color: const Color(0xFF0A2351), child: const Text('FEE RECEIPT', textAlign: TextAlign.center, style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))), Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Name:'), Text(widget.student['name'])]), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Month:'), Text(month)]), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Amount:'), Text('₹${widget.student['fee']}')])]))])); }
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: Text(widget.student['name']), backgroundColor: const Color(0xFF0A2351), foregroundColor: Colors.white), body: Column(children: [Expanded(child: GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.1, crossAxisSpacing: 8, mainAxisSpacing: 8), itemCount: widget.months.length, itemBuilder: (c, i) { String m = widget.months[i]; bool paid = payments.containsKey(m); return InkWell(onTap: () { if(!paid) { setState(() => payments[m] = DateTime.now().toString()); widget.onUpdate(payments); } shareReceipt(m); }, child: Container(decoration: BoxDecoration(color: paid? Colors.green.shade50 : Colors.white, border: Border.all(color: paid? Colors.green : Colors.orange.shade200), borderRadius: BorderRadius.circular(10)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(m, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), Icon(paid? Icons.verified : Icons.hourglass_bottom, size: 16, color: paid? Colors.green : Colors.orange), Text(paid? "Paid" : "Pending", style: const TextStyle(fontSize: 9))]))); })), Offstage(child: Screenshot(controller: sc, child: receiptWidget(lastMonth.isEmpty? widget.months[0] : lastMonth)))])); }
}
