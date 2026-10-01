import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const SaikrupaApp());

class SaikrupaApp extends StatelessWidget {
  const SaikrupaApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // तुझी लिस्ट आधीच टाकली आहे
  List<Map<String, dynamic>> students = [
    {"name": "विहान लुपे", "age": 6, "fee": 360, "batch": "सकाळ", "payments": {}},
    {"name": "क्रिशा किरमे", "age": 10, "fee": 400, "batch": "सकाळ", "payments": {}},
    {"name": "अंबरशुमन इतापे", "age": 10, "fee": 500, "batch": "सकाळ", "payments": {}},
    {"name": "आराध्या यादव", "age": 5, "fee": 360, "batch": "सकाळ", "payments": {}},
    {"name": "सम्यक भिर्के", "age": 5, "fee": 360, "batch": "सकाळ", "payments": {}},
    {"name": "श्रेया गादेकर", "age": 11, "fee": 500, "batch": "सकाळ", "payments": {}},
    {"name": "स्वरा पाटील", "age": 3, "fee": 360, "batch": "सकाळ", "payments": {}},
    {"name": "स्वरूप पाटील", "age": 3, "fee": 360, "batch": "सकाळ", "payments": {}},
    {"name": "तेजल पाटील", "age": 25, "fee": 550, "batch": "संध्याकाळ", "payments": {}},
    {"name": "पूर्वा पाटील", "age": 20, "fee": 550, "batch": "संध्याकाळ", "payments": {}},
    {"name": "संस्कृती", "age": 14, "fee": 500, "batch": "संध्याकाळ", "payments": {}},
    {"name": "स्वरांश", "age": 10, "fee": 400, "batch": "संध्याकाळ", "payments": {}},
  ];

  String filterBatch = "सगळे";
  final List<String> months = ["जून","जुलै","ऑगस्ट","सप्टेंबर","ऑक्टोबर","नोव्हेंबर","डिसेंबर","जानेवारी","फेब्रुवारी","मार्च","एप्रिल","मे"];
  bool firstLoad = true;

  @override void initState() { super.initState(); loadData(); }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('saikrupa_final_v1');
    if (data!= null) {
      setState(() { students = List<Map<String, dynamic>>.from(jsonDecode(data)); firstLoad = false; });
    } else {
      saveData(); // पहिल्यांदा तुझी लिस्ट save कर
    }
  }
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('saikrupa_final_v1', jsonEncode(students));
  }

  void addOrEditStudent({Map<String, dynamic>? existing, int? index}) {
    final nameCtrl = TextEditingController(text: existing?['name']?? '');
    final feeCtrl = TextEditingController(text: existing?['fee']?.toString()?? '500');
    String batch = existing?['batch']?? 'सकाळ';
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text(existing == null? "नवीन विद्यार्थी" : "Edit करा - फी बदलता येईल"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "नाव")),
        const SizedBox(height: 10),
        TextField(controller: feeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "महिन्याची फी ₹ - 360/500/550")),
        DropdownButton<String>(value: batch, isExpanded: true, onChanged: (v){ batch = v!; (c as Element).markNeedsBuild(); }, items: ["सकाळ","संध्याकाळ"].map((e)=>DropdownMenuItem(value:e, child: Text(e))).toList())
      ]),
      actions: [
        if(index!=null) TextButton(onPressed: (){ setState(()=>students.removeAt(index)); saveData(); Navigator.pop(context); }, child: const Text("Delete", style: TextStyle(color: Colors.red))),
        TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("रद्द")),
        ElevatedButton(onPressed: (){
          if(nameCtrl.text.isEmpty) return;
          final student = {"name": nameCtrl.text, "fee": int.tryParse(feeCtrl.text)?? 500, "batch": batch, "payments": existing?['payments']?? {}};
          setState(()=> index!=null? students[index]=student : students.add(student));
          saveData(); Navigator.pop(context);
        }, child: const Text("Save"))
      ],
    ));
  }

  @override Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered = filterBatch=="सगळे"? students : students.where((s)=>s['batch']==filterBatch).toList();
    return Scaffold(
      appBar: AppBar(title: const Text("SAIKRUPA CLASSES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFFFF8C00)),
      body: Column(children: [
        Container(color: Colors.orange.shade50, padding: const EdgeInsets.all(12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("एकूण: ${filtered.length} मुले", style: const TextStyle(fontWeight: FontWeight.bold)),
          ToggleButtons(isSelected: [filterBatch=="सगळे", filterBatch=="सकाळ", filterBatch=="संध्याकाळ"], onPressed: (i)=>setState(()=>filterBatch=["सगळे","सकाळ","संध्याकाळ"][i]), children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("सगळे")), Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("सकाळ")), Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("संध्या"))])
        ])),
        Expanded(child: ListView.builder(itemCount: filtered.length, itemBuilder: (c,i){
          final s = filtered[i]; int realIndex = students.indexOf(s); int paid = (s['payments'] as Map).length;
          return Card(margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), child: ListTile(
            onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=> StudentDetail(student: s, months: months, onUpdate: (newPay){ setState(()=>students[realIndex]['payments']=newPay); saveData(); }))),
            onLongPress: ()=>addOrEditStudent(existing: s, index: realIndex),
            leading: CircleAvatar(backgroundColor: paid==12?Colors.green:Colors.orange, child: Text(s['name'][0].toUpperCase(), style: const TextStyle(color: Colors.white))),
            title: Text("${s['name']} (${s['age']})", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${s['batch']} | ₹${s['fee']}/महिना | $paid/12 Paid - Long press ने फी बदला"),
            trailing: Icon(paid==12? Icons.verified : Icons.pending, color: paid==12?Colors.green:Colors.red),
          ));
        }))
      ]),
      floatingActionButton: FloatingActionButton(onPressed: ()=>addOrEditStudent(), backgroundColor: const Color(0xFFFF8C00), child: const Icon(Icons.add, color: Colors.white)),
    );
  }
}

class StudentDetail extends StatefulWidget {
  final Map<String, dynamic> student; final List<String> months; final Function(Map) onUpdate;
  const StudentDetail({super.key, required this.student, required this.months, required this.onUpdate});
  @override State<StudentDetail> createState()=> _StudentDetailState();
}
class _StudentDetailState extends State<StudentDetail>{
  late Map payments;
  @override void initState(){ super.initState(); payments = Map.from(widget.student['payments']?? {}); }
  @override Widget build(BuildContext context){
    int pendingMonths = 12 - payments.length;
    int pendingAmount = pendingMonths * (widget.student['fee'] as int);
    return Scaffold(
      appBar: AppBar(title: Text(widget.student['name']), backgroundColor: const Color(0xFFFF8C00)),
      body: Column(children: [
        Container(width: double.infinity, color: pendingAmount==0?Colors.green.shade100:Colors.red.shade100, padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("${widget.student['name']} | फी: ₹${widget.student['fee']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(pendingAmount==0? "सगळी फी भरली! ✅" : "बाकी: $pendingMonths महिने = ₹$pendingAmount", style: TextStyle(color: pendingAmount==0?Colors.green:Colors.red, fontWeight: FontWeight.bold)),
        ])),
        Expanded(child: ListView.builder(itemCount: widget.months.length, itemBuilder: (c,i){
          String m = widget.months[i]; bool isPaid = payments.containsKey(m);
          return ListTile(
            leading: Icon(isPaid?Icons.check_box:Icons.check_box_outline_blank, color: isPaid?Colors.green:Colors.grey),
            title: Text(m, style: TextStyle(fontWeight: isPaid?FontWeight.bold:FontWeight.normal)),
            subtitle: Text(isPaid? "Paid on ${payments[m]} | ₹${widget.student['fee']}" : "बाकी आहे"),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: isPaid?Colors.red:Colors.green),
              onPressed: (){ setState(()=> isPaid? payments.remove(m) : payments[m] = "${DateTime.now().day}/${DateTime.now().month}"); widget.onUpdate(payments); },
              child: Text(isPaid?"रद्द करा":"जमा", style: const TextStyle(color: Colors.white)),
            ),
          );
        }))
      ]),
    );
  }
}
