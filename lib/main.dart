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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
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

  final List<String> months = [
    "जून","जुलै","ऑगस्ट","सप्टेंबर","ऑक्टोबर","नोव्हेंबर",
    "डिसेंबर","जानेवारी","फेब्रुवारी","मार्च","एप्रिल","मे"
  ];

  final List<Map<String, dynamic>> defaultStudents = [
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

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final p = await SharedPreferences.getInstance();
    final d = p.getString('sc_v6_edit');
    if (d != null) {
      setState(() {
        students = List<Map<String, dynamic>>.from(jsonDecode(d));
      });
    } else {
      setState(() {
        students = List<Map<String, dynamic>>.from(defaultStudents);
      });
    }
  }

  Future<void> saveData() async {
    final p = await SharedPreferences.getInstance();
    p.setString('sc_v6_edit', jsonEncode(students));
  }

  Widget logoWidget(double size) {
    return ClipOval(
      child: Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: Color(0xFF0A2351),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text("SC",
                  style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ),
          );
        },
      ),
    );
  }

  void showAddEditDialog({Map<String, dynamic>? editData, int? editIndex}) {
    TextEditingController nameC =
        TextEditingController(text: editData != null ? editData['name'] : "");
    TextEditingController feeC = TextEditingController(
        text: editData != null ? editData['fee'].toString() : "400");
    String batch = editData != null ? editData['batch'] : "सकाळ";

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setD) {
            return AlertDialog(
              title: Text(editData == null
                  ? "नवीन विद्यार्थी"
                  : "एडिट करा"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameC,
                    decoration: const InputDecoration(
                        labelText: "नाव", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: feeC,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: "फी ₹", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  DropdownButton
