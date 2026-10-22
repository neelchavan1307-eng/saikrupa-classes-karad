// Saikrupa Classes - Light 3D Blocks - No Search
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'receipt_screen.dart';

void main() {
  runApp(const SaikrupaApp());
}

class SaikrupaApp extends StatelessWidget {
  const SaikrupaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dashboard(),
    );
  }
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
      for (var m in (b['p'] as List)) {
        if (m >= 1 && m <= 12) m12[m - 1] = 1;
      }
      return {
        "name": (b['n'] as String).trim(),
        "age": b['a'].toString(),
        "std": b['s'].toString(),
        "fee": b['f'],
        "mobile": "",
        "months": m12
      };
    }).toList();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    var p = await SharedPreferences.getInstance();
    setState(() {
      tName = p.getString('t_name') ?? tName;
      tMobile = p.getString('t_mobile') ?? tMobile;
      tAddr = p.getString('t_addr') ?? tAddr;
    });
  }

  Future<void> _saveProfile() async {
    var p = await SharedPreferences.getInstance();
    await p.setString('t_name', tName);
    await p.setString('t_mobile', tMobile);
    await p.setString('t_addr', tAddr);
  }

  void pickMonth(Map<String, dynamic> s) {
    List<int> months = List<int>.from(s['months']);
    List<String> mNames = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    List<int> paidIdx = [];
    for (int i = 0; i < 12; i++) {
      if (months[i] == 1) paidIdx.add(i);
    }
    if (paidIdx.isEmpty) {
      openReceipt(s, mNames[DateTime.now().month - 1], s['fee'].toString());
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("${s['name']} - Mahina Nivda"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: paidIdx.map((i) {
            return ListTile(
              title: Text(mNames[i]),
              trailing: Text("Rs.${s['fee']}"),
              onTap: () {
                Navigator.pop(context);
                openReceipt(s, mNames[i], s['fee'].toString());
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void openReceipt(Map<String, dynamic> s, String oneMonth, String amount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptScreen(
          studentName: s['name'],
          amount: amount,
          joiningDate: "01/06/2024",
          paidDate: "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
          monthPaid: oneMonth,
          mode: "Cash",
          receiptNo: "SK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
          fee: s['fee'].toString(),
        ),
      ),
    );
  }

  void openEdit(Map<String, dynamic> s, int idx) async {
    var u = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditFull(student: s)));
    if (u != null && u is Map) {
      setState(() {
        students[idx] = Map<String, dynamic>.from(u);
      });
    }
  }

  void deleteStud(int idx) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete karaycha?"),
        content: Text("${students[idx]['name']} la delete karu?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Nako")),
          ElevatedButton(
            onPressed: () {
              setState(() => students.removeAt(idx));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var filtered = students.asMap().entries.where((e) {
      var s = e.value;
      bool hasB = (s['months'] as List).contains(0);
      if (filter == "Baki" && !hasB) return false;
      if (filter == "Jama" && hasB) return false;
      return true;
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/glass_bg.png', fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: const Color(0xFFFFE6D5)))),
          Positioned.fill(child: Container(color: Colors.white.withOpacity(0.60))),
          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 15)]),
                  child: Row(
                    children: [
                      Container(width: 74, height: 74, decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.orange, width: 2)), child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.asset('assets/logo.png', fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.school, size: 38, color: Colors.orange)))),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("SAIKRUPA CLASSES", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)), Text(tName, style: const TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold)), Text(tAddr, style: const TextStyle(fontSize: 11), maxLines: 1), Row(children: [const Icon(Icons.phone, size: 12, color: Colors.orange), const SizedBox(width: 4), Text(tMobile, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))])])),
                      IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () {
                        var nC = TextEditingController(text: tName);
                        var mC = TextEditingController(text: tMobile);
                        var aC = TextEditingController(text: tAddr);
                        showDialog(context: context, builder: (_) => AlertDialog(title: const Text("Mahiti Badla"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nC), TextField(controller: mC), TextField(controller: aC)]), actions: [ElevatedButton(onPressed: () { setState(() { tName = nC.text; tMobile = mC.text; tAddr = aC.text; }); _saveProfile(); Navigator.pop(context); }, child: const Text("Save"))]));
                      }),
                    ],
                  ),
                ),
                Row(children: ["Sarv","Baki","Jama"].map((f) => Padding(padding: const EdgeInsets.only(left: 14), child: ChoiceChip(label: Text(f), selected: filter == f, onSelected: (_) => setState(() => filter = f), selectedColor: Colors.orange.shade200))).toList()),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: filtered.length,
                    itemBuilder: (_, idx) {
                      var entry = filtered[idx];
                      int realIndex = entry.key;
                      var s = entry.value;
                      List<Color> bg = lightColors[realIndex % lightColors.length];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(colors: bg), boxShadow: [BoxShadow(color: bg[1].withOpacity(0.6), blurRadius: 12, offset: const Offset(0,6))], border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.8)),
                        child: Dismissible(
                          key: ValueKey(s['name'] + realIndex.toString() + idx.toString()),
                          direction: DismissDirection.startToEnd,
                          background: Container(decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)), alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 20), child: const Text("Swipe kara -> Receipt pathva", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          confirmDismiss: (d) async { pickMonth(s); return false; },
                          child: ListTile(
                            onTap: () => openEdit(s, realIndex),
                            onLongPress: () => deleteStud(realIndex),
                            leading: Container(width: 52, height: 52, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.white), child: Center(child: Text(s['name'][0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)))),
                            title: Text(s['name'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            subtitle: const Text("Swipe -> Receipt | Long press - Delete", style: TextStyle(fontSize: 9, color: Colors.black54)),
                            trailing: IconButton(icon: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.receipt_long, color: Colors.green, size: 20)), onPressed: () => pickMonth(s)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          var r = await showDialog(context: context, builder: (_) => AddStudentDialog());
          if (r != null && r is Map) setState(() => students.add(Map<String,dynamic>.from(r)));
        },
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Navin Vidyarthi", style: TextStyle(color: Colors.white)),
      ),
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
  void initState() {
    super.initState();
    nameC = TextEditingController(text: widget.student['name']);
    feeC = TextEditingController(text: widget.student['fee'].toString());
    ageC = TextEditingController(text: widget.student['age']);
    stdC = TextEditingController(text: widget.student['std']);
    months = List<int>.from(widget.student['months']);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameC, decoration: const InputDecoration(labelText: "Nav")),
            TextField(controller: ageC, decoration: const InputDecoration(labelText: "Vay")),
            TextField(controller: stdC, decoration: const InputDecoration(labelText: "Iyatta")),
            TextField(controller: feeC, decoration: const InputDecoration(labelText: "Fee"), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: List.generate(12, (i) {
              bool p = months[i] == 1;
              return GestureDetector(onTap: () => setState(() => months[i] = p ? 0 : 1), child: Container(width: 60, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: p ? Colors.green : Colors.pink.shade100, borderRadius: BorderRadius.circular(10)), child: Column(children: [Text(["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"][i]), Icon(p ? Icons.check_circle : Icons.cancel, size: 14)])));
            })),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () { var u = {"name": nameC.text.trim(), "age": ageC.text, "std": stdC.text, "fee": int.tryParse(feeC.text) ?? 600, "mobile": "", "months": months}; Navigator.pop(context, u); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(double.infinity, 50)), child: const Text("SAVE", style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }
}

class AddStudentDialog extends StatefulWidget {
  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  var nameC = TextEditingController();
  var feeC = TextEditingController(text: "500");
  var ageC = TextEditingController(text: "6");
  var stdC = TextEditingController(text: "1");
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Navin Vidyarthi"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nameC, decoration: const InputDecoration(labelText: "Nav")), TextField(controller: feeC, decoration: const InputDecoration(labelText: "Fee"))]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(onPressed: () { if (nameC.text.trim().isEmpty) return; var s = {"name": nameC.text.trim(), "age": ageC.text, "std": stdC.text, "fee": int.tryParse(feeC.text) ?? 500, "mobile": "", "months": List.filled(12,0)}; Navigator.pop(context, s); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: const Text("Add", style: TextStyle(color: Colors.white))),
      ],
    );
  }
}
