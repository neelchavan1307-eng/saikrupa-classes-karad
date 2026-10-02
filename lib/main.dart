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
  @override Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true), home: const HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentTab = 0;
  String contactNumber = "तुमचा मोबाईल नंबर इथे टाका";
  List<Map<String, dynamic>> students = [
    {"name": "विहान लुपे", "age": 6, "fee": 360, "batch": "सकाळ", "payments": {}, "joining": "5 Sep 2025", "parentPhone": ""},
    {"name": "क्रिशा किरमे", "age": 10, "fee": 400, "batch": "सकाळ", "payments": {}, "joining": "5 Sep 2025", "parentPhone": ""},
    {"name": "अंबरशुमन इतापे", "age": 10, "fee": 500, "batch": "सकाळ", "payments": {}, "joining": "5 Sep 2025", "parentPhone": ""},
    {"name": "आराध्या यादव", "age": 5, "fee": 360, "batch": "सकाळ", "payments": {}, "joining": "5 Sep 2025", "parentPhone": ""},
    {"name": "सम्यक भिर्के", "age": 5, "fee": 360, "batch": "सकाळ", "payments": {}, "joining": "5 Sep 2025", "parentPhone": ""},
    {"name": "श्रेया गादेकर", "age": 11, "fee": 500, "batch": "सकाळ", "payments": {}, "joining": "5 Sep 2025", "parentPhone": ""},
    {"name": "स्वरा पाटील", "age": 3, "fee": 360, "batch": "सकाळ", "payments": {}, "joining": "5 Sep 2025", "parentPhone": ""},
    {"name": "स्वरूप पाटील", "age": 3, "fee": 360, "batch": "सकाळ", "payments": {}, "joining": "5 Sep 2025", "parentPhone": ""},
    {"name": "तेजल पाटील", "age": 25, "fee": 550, "batch": "संध्याकाळ", "payments": {}, "joining": "5 Sep 2025", "parentPhone": ""},
    {"name": "पूर्वा पाटील", "age": 20, "fee": 550, "batch": "संध्याकाळ", "payments": {}, "joining": "5 Sep 2025", "parentPhone": ""},
    {"name": "संस्कृती", "age": 14, "fee": 500, "batch": "संध्याकाळ", "payments": {}, "joining": "5 Sep 2025", "parentPhone": ""},
    {"name": "स्वरांश", "age": 10, "fee": 400, "batch": "संध्याकाळ", "payments": {}, "joining": "5 Sep 2025", "parentPhone": ""},
  ];
  String filterBatch = "सगळे";
  final List<String> months = ["जून","जुलै","ऑगस्ट","सप्टेंबर","ऑक्टोबर","नोव्हेंबर","डिसेंबर","जानेवारी","फेब्रुवारी","मार्च","एप्रिल","मे"];
  @override void initState() { super.initState(); loadData(); }
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('saikrupa_final_v1');
    final savedContact = prefs.getString('contact_number');
    if (data!= null) setState(() { students = List<Map<String, dynamic>>.from(jsonDecode(data)); });
    if (savedContact!= null) setState(() { contactNumber = savedContact; });
    else saveData();
  }
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('saikrupa_final_v1', jsonEncode(students));
  }
  Future<void> saveContact(String num) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('contact_number', num);
    setState(()=> contactNumber = num);
  }
  void editContactDialog() {
    final ctrl = TextEditingController(text: contactNumber.contains("टाका")? "" : contactNumber);
    showDialog(context: context, builder: (c)=> AlertDialog(
      title: Text("मोबाईल नंबर टाका"),
      content: TextField(controller: ctrl, keyboardType: TextInputType.phone, decoration: InputDecoration(hintText: "उदा. 9876543210")),
      actions: [TextButton(onPressed: ()=> Navigator.pop(c), child: Text("रद्द")), ElevatedButton(onPressed: (){ saveContact(ctrl.text); Navigator.pop(c); }, child: Text("Save"))],
    ));
  }
  void addOrEditStudent({Map<String, dynamic>? existing, int? index}) {
    final nameCtrl = TextEditingController(text: existing?['name']?? '');
    final feeCtrl = TextEditingController(text: existing?['fee']?.toString()?? '500');
    final phoneCtrl = TextEditingController(text: existing?['parentPhone']?? '');
    String batch = existing?['batch']?? 'सकाळ';
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text(existing == null? "नवीन विद्यार्थी" : "Edit करा"),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "नाव")),
        const SizedBox(height: 10),
        TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "पालकांचा WhatsApp नंबर")),
        const SizedBox(height: 10),
        TextField(controller: feeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "महिन्याची फी ₹")),
        DropdownButton<String>(value: batch, isExpanded: true, onChanged: (v){ batch = v!; (c as Element).markNeedsBuild(); }, items: ["सकाळ","संध्याकाळ"].map((e)=>DropdownMenuItem(value:e, child: Text(e))).toList())
      ])),
      actions: [
        if(index!=null) TextButton(onPressed: (){ setState(()=>students.removeAt(index)); saveData(); Navigator.pop(context); }, child: const Text("Delete", style: TextStyle(color: Colors.red))),
        TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("रद्द")),
        ElevatedButton(onPressed: (){
          if(nameCtrl.text.isEmpty) return;
          final student = {"name": nameCtrl.text, "fee": int.tryParse(feeCtrl.text)?? 500, "batch": batch, "payments": existing?['payments']?? {}, "age": existing?['age']?? 10, "joining": existing?['joining']?? "5 Sep 2025", "parentPhone": phoneCtrl.text};
          setState(()=> index!=null? students[index]=student : students.add(student));
          saveData(); Navigator.pop(context);
        }, child: const Text("Save"))
      ],
    ));
  }
  Widget buildProfile() {
    return ListView(padding: EdgeInsets.all(20), children: [
      SizedBox(height: 20),
      Center(child: Image.asset('assets/logo.png', height: 120, errorBuilder: (c,e,s)=> Icon(Icons.school, size: 100, color: Colors.orange))),
      SizedBox(height: 15),
      Center(child: Text('SAIKRUPA CLASSES', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFFF8C00)))),
      SizedBox(height: 5),
      Center(child: Text('Morya Park, Sangodi Road, Yelwadi', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
      Divider(height: 40),
      ListTile(leading: Icon(Icons.location_on, color: Colors.orange), title: Text('पत्ता'), subtitle: Text('Morya Park, Sangodi Road, Yelwadi, Pune')),
      ListTile(leading: Icon(Icons.phone, color: Colors.orange), title: Text('संपर्क - Edit करण्यासाठी टॅप करा'), subtitle: Text(contactNumber), onTap: editContactDialog, trailing: Icon(Icons.edit, color: Colors.orange)),
      ListTile(leading: Icon(Icons.verified, color: Colors.orange), title: Text('App Version'), subtitle: Text('v2.1 - Gold Receipt Update')),
    ]);
  }
  @override Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered = filterBatch=="सगळे"? students : students.where((s)=>s['batch']==filterBatch).toList();
    return Scaffold(
      appBar: AppBar(title: Text(currentTab==0? "SAIKRUPA CLASSES" : "Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFFFF8C00)),
      bottomNavigationBar: BottomNavigationBar(currentIndex: currentTab, onTap: (i)=>setState(()=>currentTab=i), selectedItemColor: Color(0xFFFF8C00), items: [BottomNavigationBarItem(icon: Icon(Icons.people), label: "विद्यार्थी"), BottomNavigationBarItem(icon: Icon(Icons.person), label: "प्रोफाइल")]),
      body: currentTab==1? buildProfile() : Column(children: [
        Container(color: Colors.orange.shade50, padding: const EdgeInsets.all(12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("एकूण: ${filtered.length} मुले", style: const TextStyle(fontWeight: FontWeight.bold)),
          ToggleButtons(isSelected: [filterBatch=="सगळे", filterBatch=="सकाळ", filterBatch=="संध्याकाळ"], onPressed: (i)=>setState(()=>filterBatch=["सगळे","सकाळ","संध्याकाळ"][i]), children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("सगळे")), Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("सकाळ")), Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("संध्या"))])
        ])),
        Expanded(child: ListView.builder(itemCount: filtered.length, itemBuilder: (c,i){
          final s = filtered[i]; int realIndex = students.indexOf(s); int paid = (s['payments'] as Map).length;
          return Card(margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), child: ListTile(
            onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=> StudentDetail(student: s, months: months, onUpdate: (newPay){ setState(()=>students[realIndex]['payments']=newPay); saveData(); }))),
            onLongPress: ()=>addOrEditStudent(existing: s, index: realIndex),
            leading: CircleAvatar(backgroundColor: paid==12?Colors.green:Colors.orange, child: Text(s['name'][0].toUpperCase(), style: const TextStyle
