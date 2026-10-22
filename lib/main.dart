import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'receipt_screen.dart';

void main() => runApp(const SaikrupaApp());

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
  List<Map<String, dynamic>> students = [
    {"name": "Vihan Tupe", "age": "9", "std": "3", "fee": 600, "months": [0,0,0,0,0,0,1,1,1,0,0,1]},
    {"name": "Krisha Kirme", "age": "10", "std": "10", "fee": 1200, "months": [1,0,0,0,0,0,1,1,0,0,0,0]},
    {"name": "Anshuman", "age": "6", "std": "3", "fee": 600, "months": [0,0,0,0,0,0,0,0,1,1,0,1]},
  ];

  String filter = "Sarv";
  String search = "";
  String tName = "टीचर-स्नेहल चव्हाण";
  String tMobile = "9822001122";
  String tAddr = "मोरया पार्क, सांगोडी रोड, येलवाडी.";

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    var p = await SharedPreferences.getInstance();
    setState(() {
      tName = p.getString('t_name') ?? tName;
      tMobile = p.getString('t_mobile') ?? tMobile;
      tAddr = p.getString('t_addr') ?? tAddr;
    });
  }

  Future<void> _save() async {
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
            TextField(controller: nC, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: mC, decoration: const InputDecoration(labelText: "Mobile")),
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
              _save();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void openReceipt(Map<String, dynamic> s) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptScreen(
          studentName: s['name'],
          amount: s['fee'].toString(),
          joiningDate: "01/06/2024",
          paidDate: "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
          monthPaid: "Aug",
          mode: "Cash",
          receiptNo: "SK${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var filtered = students.where((s) {
      if (search.isNotEmpty && !s['name'].toString().toLowerCase().contains(search.toLowerCase())) return false;
      return true;
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/saibaba_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFFFFE6D5)),
            ),
          ),
          Positioned.fill(child: Container(color: Colors.white.withOpacity(0.78))),
          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.school, color: Colors.white)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("SAIKRUPA CLASSES", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(tName, style: const TextStyle(fontSize: 12, color: Colors.red)),
                            Text(tAddr, style: const TextStyle(fontSize: 10)),
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
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      var s = filtered[i];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Text(s['name'][0])),
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
            students.add({"name": "New Student", "age": "6", "std": "1", "fee": 500, "months": List.filled(12, 0)});
          });
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
