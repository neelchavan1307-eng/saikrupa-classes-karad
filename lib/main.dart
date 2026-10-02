import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(const SaikrupaApp());
}

class SaikrupaApp extends StatelessWidget {
  const SaikrupaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentTab = 0;
  String contactNumber = "9876543210";
  List<Map<String, dynamic>> students = [
    {"name": "विहान लुपे", "fee": 360, "batch": "सकाळ", "payments": {}},
    {"name": "क्रिशा किरमे", "fee": 400, "batch": "सकाळ", "payments": {}},
    {"name": "अंबरशुमन इतापे", "fee": 500, "batch": "सकाळ", "payments": {}},
    {"name": "आराध्या यादव", "fee": 360, "batch": "सकाळ", "payments": {}},
    {"name": "सम्यक भिर्के", "fee": 360, "batch": "सकाळ", "payments": {}},
    {"name": "श्रेया गादेकर", "fee": 500, "batch": "सकाळ", "payments": {}},
    {"name": "स्वरा पाटील", "fee": 360, "batch": "सकाळ", "payments": {}},
    {"name": "स्वरूप पाटील", "fee": 360, "batch": "सकाळ", "payments": {}},
    {"name": "तेजल पाटील", "fee": 550, "batch": "संध्याकाळ", "payments": {}},
    {"name": "पूर्वा पाटील", "fee": 550, "batch": "संध्याकाळ", "payments": {}},
    {"name": "संस्कृती", "fee": 500, "batch": "संध्याकाळ", "payments": {}},
    {"name": "स्वरांश", "fee": 400, "batch": "संध्याकाळ", "payments": {}},
  ];

  String filterBatch = "सगळे";
  final List<String> months = ["जून","जुलै","ऑगस्ट","सप्टेंबर","ऑक्टोबर","नोव्हेंबर","डिसेंबर","जानेवारी","फेब्रुवारी","मार्च","एप्रिल","मे"];

  @override
  void initState() { super.initState(); loadData(); }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('saikrupa_final_v1');
    if (data!= null) {
      setState(() {
        students = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('saikrupa_final_v1', jsonEncode(students));
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered = filterBatch == "सगळे"? students : students.where((s) => s['batch'] == filterBatch).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(currentTab == 0? "SAIKRUPA CLASSES" : "Profile"),
        backgroundColor: Colors.orange,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        onTap: (i) => setState(() => currentTab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "विद्यार्थी"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "प्रोफाइल"),
        ],
      ),
      body: currentTab == 1
         ? Center(child: Text('SAIKRUPA CLASSES\nMorya Park, Sangodi Road', textAlign: TextAlign.center))
          : Column(
              children: [
                Container(
                  color: Colors.orange.shade50,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("एकूण: ${filtered.length} मुले", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ToggleButtons(
                        isSelected: [filterBatch == "सगळे", filterBatch == "सकाळ", filterBatch == "संध्याकाळ"],
                        onPressed: (i) => setState(() => filterBatch = ["सगळे", "सकाळ", "संध्याकाळ"][i]),
                        children: const [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("सगळे")),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("सकाळ")),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("संध्या")),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (c, i) {
                      final s = filtered[i];
                      int realIndex = students.indexOf(s);
                      int paid = (s['payments'] as Map).length;
                      return Card(
                        child: ListTile(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentDetail(student: s, months: months, onUpdate: (newPay) { setState(() => students[realIndex]['payments'] = newPay); saveData(); }))),
                          leading: CircleAvatar(child: Text(s['name'][0])),
                          title: Text(s['name']),
                          subtitle: Text("${s['batch']} | ₹${s['fee']} | $paid/12 Paid"),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class StudentDetail extends StatefulWidget {
  final Map<String, dynamic> student;
  final List<String> months;
  final Function(Map) onUpdate;
  const StudentDetail({super.key, required this.student, required this.months, required this.onUpdate});
  @override
  State<StudentDetail> createState() => _StudentDetailState();
}

class _StudentDetailState extends State<StudentDetail> {
  late Map payments;
  final ScreenshotController screenshotController = ScreenshotController();
  String lastPaidMonth = "";

  @override
  void initState() {
    super.initState();
    payments = Map.from(widget.student['payments']?? {});
  }

  Future<void> shareReceipt(String month) async {
    setState(() => lastPaidMonth = month);
    await Future.delayed(const Duration(milliseconds: 400));
    final bytes = await screenshotController.capture();
    if (bytes == null) return;
    final dir = await getTemporaryDirectory();
    final file = await File('${dir.path}/receipt.png').create();
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: '${widget.student['name']} - $month Fee Receipt');
  }

  Widget receiptWidget(String month) {
    return Container(
      width: 400,
      color: const Color(0xFFFFFEF5),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('SAIKRUPA CLASSES', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0A2351))),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: const Color(0xFF0A2351),
            child: const Text('FEE RECEIPT', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 15),
          Text('Name: ${widget.student['name']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Month: $month'),
          const SizedBox(height: 8),
          Text('Fee: ₹${widget.student['fee']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text('Thank You!'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.student['name'])),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.2, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: widget.months.length,
              itemBuilder: (c, i) {
                String m = widget.months[i];
                bool isPaid = payments.containsKey(m);
                return InkWell(
                  onTap: () {
                    if (!isPaid) {
                      setState(() => payments[m] = DateTime.now().toString());
                      widget.onUpdate(payments);
                    }
                    shareReceipt(m);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isPaid? Colors.green.shade100 : Colors.orange.shade50,
                      border: Border.all(color: isPaid? Colors.green : Colors.orange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(m, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Icon(isPaid? Icons.check_circle : Icons.pending, size: 18),
                        Text(isPaid? "Paid" : "Pending", style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 1,
            child: SingleChildScrollView(
              child: Screenshot(controller: screenshotController, child: receiptWidget(lastPaidMonth.isEmpty? widget.months[0] : lastPaidMonth)),
            ),
          ),
        ],
      ),
    );
  }
}
