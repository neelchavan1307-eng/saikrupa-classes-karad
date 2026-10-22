// PART 1 - Saikrupa Classes
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'receipt_screen.dart';

void main() => runApp(const SaikrupaApp());

class SaikrupaApp extends StatelessWidget {
  const SaikrupaApp({super.key});
  @override
  Widget build(BuildContext c) => const MaterialApp(debugShowCheckedModeBanner: false, home: Dashboard());
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final backupRaw = [
    {"n": "Vihan Tupe", "a": 9, "s": 3, "f": 600, "p": [7, 8, 9, 1]},
    {"n": "Krisha Kirme", "a": 10, "s": 10, "f": 1200, "p": [7, 8, 1]},
    {"n": "Anshuman", "a": 6, "s": 3, "f": 600, "p": [9, 7, 8]},
    {"n": "samayak", "a": 6, "s": 1, "f": 500, "p": [7, 8, 9]},
    {"n": "Aradhya", "a": 6, "s": 4, "f": 700, "p": [8, 9]},
    {"n": "shreya", "a": 6, "s": 2, "f": 500, "p": [8]},
    {"n": "Aravi", "a": 6, "s": 1, "f": 500, "p": [8]},
    {"n": "Swarangi swarup", "a": 6, "s": 6, "f": 700, "p": [7]},
    {"n": "swaransh", "a": 6, "s": 1, "f": 500, "p": [7, 8, 9]},
    {"n": "Tejal", "a": 6, "s": 5, "f": 400, "p": []},
    {"n": "Poorva", "a": 6, "s": 5, "f": 200, "p": [8]},
    {"n": "Sanskruti", "a": 6, "s": 6, "f": 850, "p": [9]},
    {"n": "piyush", "a": 6, "s": 3, "f": 600, "p": []},
  ];

  late List<Map<String, dynamic>> students;
  String filter = "Sarv";
  String tName = "Teacher Snehal Chavan";
  String tMobile = "9822001122";
  String tAddr = "Morya Park, Sangodi Road, Yelwadi";

  final List<List<Color>> lightColors = [
    [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
    [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
    [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
    [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
    [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
    [Color(0xFFFFF9C4), Color(0xFFFFF59D)],
    [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
    [Color(0xFFF1F8E9), Color(0xFFDCEDC8)],
  ];

  @override
  void initState() {
    super.initState();
    students = backupRaw.map((b) {
      List<int> m12 = List.filled(12, 0);
      for (var m in (b['p'] as List)) if (m >= 1 && m <= 12) m12[m - 1] = 1;
      return {"name": (b['n'] as String).trim(), "age": b['a'].toString(), "std": b['s'].toString(), "fee": b['f'], "mobile": "", "months": m12};
    }).toList();
    _loadAll();
  }

  Future<void> _loadAll() async {
    var p = await SharedPreferences.getInstance();
    var saved = p.getString('students_data');
    setState(() {
      tName = p.getString('t_name') ?? tName;
      tMobile = p.getString('t_mobile') ?? tMobile;
      tAddr = p.getString('t_addr') ?? tAddr;
      if (saved != null) {
        try {
          students = List<Map<String, dynamic>>.from(
              jsonDecode(saved).map((x) => Map<String, dynamic>.from(x)));
        } catch (_) {}
      }
    });
  }

  Future<void> _saveAll() async {
    var p = await SharedPreferences.getInstance();
    await p.setString('students_data', jsonEncode(students));
    await p.setString('t_name', tName);
    await p.setString('t_mobile', tMobile);
    await p.setString('t_addr', tAddr);
  }

  Future<void> backupData() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/saikrupa_backup.json');
      await file.writeAsString(jsonEncode(students));
      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> restoreData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      if (result != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        List data = jsonDecode(content);
        setState(() => students = List<Map<String, dynamic>>.from(data.map((x) => Map<String, dynamic>.from(x))));
        await _saveAll();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restore zala!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restore Error: $e')));
    }
  }

  void pickMonthDirect(Map<String, dynamic> s) {
    List<String> mNames = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    String curMonth = mNames[DateTime.now().month - 1];
    openReceipt(s, curMonth, s['fee'].toString());
  }

  void openReceipt(Map<String, dynamic> s, String oneMonth, String amount) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ReceiptScreen(studentName: s['name'], amount: amount, joiningDate: "01/06/2024", paidDate: "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}", monthPaid: oneMonth, mode: "Cash", receiptNo: "SK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}", fee: s['fee'].toString())));
  }  void openEdit(Map<String, dynamic> s, int idx) async {
    var u = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditFull(student: s)));
    if (u != null && u is Map) {
      setState(() { students[idx] = Map<String, dynamic>.from(u); });
      _saveAll();
    }
  }

  void deleteStud(int idx) {
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text("Delete karaycha?"), content: Text("${students[idx]['name']} la delete karu?"), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Nako")), ElevatedButton(onPressed: () { setState(() => students.removeAt(idx)); _saveAll(); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text("Delete", style: TextStyle(color: Colors.white)))]));
  }

  @override
  Widget build(BuildContext context) {
    var filtered = students.asMap().entries.where((e) {
      bool hasB = (e.value['months'] as List).contains(0);
      if (filter == "Baki" && !hasB) return false;
      if (filter == "Jama" && hasB) return false;
      return true;
    }).toList();

    return Scaffold(
      body: Stack(children: [
        Positioned.fill(child: Container(color: const Color(0xFFFFE6D5))),
        SafeArea(child: Column(children: [
          Container(margin: const EdgeInsets.all(14), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 15)]), child: Row(children: [Container(width: 60, height: 60, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.orange, width: 2)), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset('assets/logo.png', errorBuilder: (_, __, ___) => const Icon(Icons.school, color: Colors.orange)))), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("SAIKRUPA CLASSES", style: TextStyle(fontWeight: FontWeight.w900)), Text(tName, style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)), Text(tAddr, style: const TextStyle(fontSize: 10), maxLines: 1)])), PopupMenuButton<String>(onSelected: (v) { if (v == 'backup') backupData(); if (v == 'restore') restoreData(); }, itemBuilder: (_) => [const PopupMenuItem(value: 'backup', child: Text('Backup Ghya')), const PopupMenuItem(value: 'restore', child: Text('Backup Restore'))], icon: const Icon(Icons.more_vert)) ])),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Row(children: [ElevatedButton.icon(onPressed: backupData, icon: const Icon(Icons.backup, size: 16), label: const Text("Backup", style: TextStyle(fontSize: 12)), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.orange, minimumSize: const Size(0, 34))), const SizedBox(width: 8), ElevatedButton.icon(onPressed: restoreData, icon: const Icon(Icons.restore, size: 16), label: const Text("Restore", style: TextStyle(fontSize: 12)), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.green, minimumSize: const Size(0, 34)))])),
          const SizedBox(height: 6),
          Row(children: ["Sarv","Baki","Jama"].map((f) => Padding(padding: const EdgeInsets.only(left: 14), child: ChoiceChip(label: Text(f), selected: filter == f, onSelected: (_) => setState(() => filter = f), selectedColor: Colors.orange.shade200))).toList()),
          const SizedBox(height: 10),
          Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 14), itemCount: filtered.length, itemBuilder: (_, idx) {
            var entry = filtered[idx];
            int realIndex = entry.key;
            var s = entry.value;
            List<Color> bg = lightColors[realIndex % lightColors.length];
            return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: LinearGradient(colors: bg), boxShadow: [BoxShadow(color: bg[1].withOpacity(0.5), blurRadius: 8, offset: const Offset(0,4))], border: Border.all(color: Colors.white, width: 1.5)), child: Dismissible(key: ValueKey(s['name'] + realIndex.toString() + idx.toString()), direction: DismissDirection.startToEnd, background: Container(decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(18)), alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 20), child: const Text("Swipe -> Direct Receipt", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), confirmDismiss: (d) async { pickMonthDirect(s); return false; }, child: ListTile(leading: Container(width: 44, height: 44, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white), child: Center(child: Text(s['name'][0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)))), title: Text(s['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)), subtitle: Text("Fee: Rs.${s['fee']} | Swipe kara", style: const TextStyle(fontSize: 10)), trailing: IconButton(icon: const Icon(Icons.receipt, color: Colors.green), onPressed: () => pickMonthDirect(s)), onTap: () => openEdit(s, realIndex))));
          })),
        ])),
      ]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () async { var r = await showDialog(context: context, builder: (_) => AddStudentDialog()); if (r != null) { setState(() => students.add(Map<String,dynamic>.from(r))); _saveAll(); } }, backgroundColor: Colors.orange, icon: const Icon(Icons.add, color: Colors.white), label: const Text("Navin", style: TextStyle(color: Colors.white))),
    );
  }
}

class EditFull extends StatefulWidget {
  final Map student;
  const EditFull({super.key, required this.student});
  @override
  State<EditFull> createState() => _EditFullState();
}

class _EditFullState extends State<EditFull> {
  late TextEditingController nameC, feeC, ageC, stdC;
  late List<int> months;
  @override
  void initState() { super.initState(); nameC = TextEditingController(text: widget.student['name']); feeC = TextEditingController(text: widget.student['fee'].toString()); ageC = TextEditingController(text: widget.student['age']); stdC = TextEditingController(text: widget.student['std']); months = List<int>.from(widget.student['months']); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Edit")), body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [TextField(controller: nameC, decoration: const InputDecoration(labelText: "Nav")), TextField(controller: feeC, decoration: const InputDecoration(labelText: "Fee")), const SizedBox(height: 10), Wrap(spacing: 6, children: List.generate(12, (i) => ChoiceChip(label: Text(["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"][i]), selected: months[i]==1, onSelected: (_) => setState(() => months[i]= months[i]==1?0:1)))), const SizedBox(height: 20), ElevatedButton(onPressed: () { Navigator.pop(context, {"name": nameC.text, "age": ageC.text, "std": stdC.text, "fee": int.tryParse(feeC.text)??500, "mobile": "", "months": months}); }, child: const Text("Save"))])));
  }
}

class AddStudentDialog extends StatefulWidget {
  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  var nameC = TextEditingController();
  var feeC = TextEditingController(text: "500");
  @override
  Widget build(BuildContext context) {
    return AlertDialog(title: const Text("Navin Vidyarthi"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nameC, decoration: const InputDecoration(labelText: "Nav")), TextField(controller: feeC, decoration: const InputDecoration(labelText: "Fee"))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")), ElevatedButton(onPressed: () { if (nameC.text.isEmpty) return; Navigator.pop(context, {"name": nameC.text, "age": "6", "std": "1", "fee": int.tryParse(feeC.text)??500, "mobile": "", "months": List.filled(12,0)}); }, child: const Text("Add"))]);
  }
}
