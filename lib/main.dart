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
  final List<Map<String, dynamic>> backupRaw = [
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
  String search = "";
  String tName = "टीचर-स्नेहल चव्हाण";
  String tMobile = "9822001122";
  String tAddr = "मोरया पार्क, सांगोडी रोड, येलवाडी.";

  @override
  void initState() {
    super.initState();
    students = backupRaw.map((b) {
      List<int> m12 = List.filled(12, 0);
      for (var m in (b['p'] as List)) {
        if (m >= 1 && m <= 12) {
          m12[m - 1] = 1;
        }
      }
      return <String, dynamic>{
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

  void editProfile() {
    var nC = TextEditingController(text: tName);
    var mC = TextEditingController(text: tMobile);
    var aC = TextEditingController(text: tAddr);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("माहिती बदला"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nC, decoration: const InputDecoration(labelText: "Teachers Name")),
            TextField(controller: mC, decoration: const InputDecoration(labelText: "Contact Number")),
            TextField(controller: aC, decoration: const InputDecoration(labelText: "Address")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                tName = nC.text;
                tMobile = mC.text;
                tAddr = aC.text;
              });
              _saveProfile();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void openReceipt(Map<String, dynamic> s) {
    List<int> months = List<int>.from(s['months']);
    int paidCount = months.where((e) => e == 1).length;
    if (paidCount == 0) paidCount = 1;
    List<String> mNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    List<String> paidM = [];
    for (int i = 0; i < 12; i++) {
      if (months[i] == 1) paidM.add(mNames[i]);
    }
    String monthStr = paidM.isEmpty ? "Not Paid" : paidM.join(", ");
    int totalAmt = paidCount * (s['fee'] as int);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptScreen(
          studentName: s['name'],
          amount: totalAmt.toString(),
          joiningDate: "01/06/2024",
          paidDate: "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
          monthPaid: monthStr,
          mode: "Cash",
          receiptNo: "SK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var filtered = students.where((s) {
      if (search.isNotEmpty && !s['name'].toLowerCase().contains(search.toLowerCase())) return false;
      bool hasB = (s['months'] as List).contains(0);
      if (filter == "Baki" && !hasB) return false;
      if (filter == "Jama" && hasB) return false;
      return true;
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/glass_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFFFFE6D5)),
            ),
          ),
          Positioned.fill(child: Container(color: Colors.white.withOpacity(0.75))),
          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.orange, width: 2)),
                        child: ClipOval(
                          child: Image.asset('assets/logo.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.school, color: Colors.orange)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("SAIKRUPA CLASSES", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(tName, style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                            Text(tAddr, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: editProfile),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    onChanged: (v) => setState(() => search = v),
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ["Sarv", "Baki", "Jama"].map((f) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: filter == f,
                        onSelected: (_) => setState(() => filter = f),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      var s = filtered[i];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Text(s['name'][0].toUpperCase())),
                          title: Text(s['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text("Std: ${s['std']}  Fee: ${s['fee']}"),
                          trailing: IconButton(icon: const Icon(Icons.receipt, color: Colors.green), onPressed: () => openReceipt(s)),
                        ),
                      );
                    },
                  ),
                ),
                const Text("Made by Pradip Chavan ✨", style: TextStyle(fontSize: 10)),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            students.add({"name": "New Student", "age": "6", "std": "1", "fee": 500, "mobile": "", "months": List.filled(12, 0)});
          });
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
