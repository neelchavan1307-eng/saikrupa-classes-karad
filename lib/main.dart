import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const SaikrupaApp());

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
    String batch = existing?['batch']?? 'सकाळ';
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text(existing == null? "नवीन विद्यार्थी" : "Edit करा"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "नाव")),
        const SizedBox(height: 10),
        TextField(controller: feeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "महिन्याची फी ₹")),
        DropdownButton<String>(value: batch, isExpanded: true, onChanged: (v){ batch = v!; (c as Element).markNeedsBuild(); }, items: ["सकाळ","संध्याकाळ"].map((e)=>DropdownMenuItem(value:e, child: Text(e))).toList())
      ]),
      actions: [
        if(index!=null) TextButton(onPressed: (){ setState(()=>students.removeAt(index)); saveData(); Navigator.pop(context); }, child: const Text("Delete", style: TextStyle(color: Colors.red))),
        TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("रद्द")),
        ElevatedButton(onPressed: (){
          if(nameCtrl.text.isEmpty) return;
          final student = {"name": nameCtrl.text, "fee": int.tryParse(feeCtrl.text)?? 500, "batch": batch, "payments": existing?['payments']?? {}, "age": existing?['age']?? 10};
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
      ListTile(leading: Icon(Icons.verified, color: Colors.orange), title: Text('App Version'), subtitle: Text('v2.1 - Pune Address')),
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
            leading: CircleAvatar(backgroundColor: paid==12?Colors.green:Colors.orange, child: Text(s['name'][0].toUpperCase(), style: const TextStyle(color: Colors.white))),
            title: Text("${s['name']}", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${s['batch']} | ₹${s['fee']}/महिना | $paid/12 Paid"),
            trailing: Icon(paid==12? Icons.verified : Icons.pending, color: paid==12?Colors.green:Colors.red),
          ));
        }))
      ]),
      floatingActionButton: currentTab==0? FloatingActionButton(onPressed: ()=>addOrEditStudent(), backgroundColor: const Color(0xFFFF8C00), child: const Icon(Icons.add, color: Colors.white)) : null,
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
  final ScreenshotController screenshotController = ScreenshotController();
  String lastPaidMonth = "";
  @override void initState(){ super.initState(); payments = Map.from(widget.student['payments']?? {}); }
  Future<void> shareReceipt(String month) async {
    setState(()=> lastPaidMonth = month);
    await Future.delayed(Duration(milliseconds: 300));
    final bytes = await screenshotController.capture();
    if(bytes==null) return;
    final dir = await getTemporaryDirectory();
    final file = await File('${dir.path}/Saikrupa_${widget.student['name']}_$month.png').create();
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: 'SAIKRUPA CLASSES, Morya Park, Sangodi Road, Yelwadi, Pune - ${widget.student['name']} - $month Fee Receipt');
  }
  Widget receiptWidget(String month) {
    return Container(width: 380, color: Colors.white, padding: EdgeInsets.all(20), child: Column(children: [
        Image.asset('assets/logo.png', height: 80, errorBuilder: (c,e,s)=> Icon(Icons.school, size: 60, color: Colors.orange)),
        SizedBox(height: 8),
        Text('SAIKRUPA CLASSES', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFF8C00))),
        Text('Morya Park, Sangodi Road, Yelwadi, Pune', style: TextStyle(fontSize: 11), textAlign: TextAlign.center),
        Divider(thickness: 2, color: Colors.orange),
        SizedBox(height: 10),
        Text('FEE RECEIPT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
        SizedBox(height: 15),
        _row('विद्यार्थी:', widget.student['name']),
        _row('महिना:', month),
        _row('फी:', '₹ ${widget.student['fee']}'),
        _row('तारीख:', payments[month]?? ''),
        _row('बॅच:', widget.student['batch']),
        SizedBox(height: 20),
        Container(width: double.infinity, padding: EdgeInsets.all(10), color: Colors.green.shade50, child: Text('PAID ✓', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16))),
        SizedBox(height: 20),
        Text('धन्यवाद! 🙏', style: TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }
  Widget _row(String l, String v) => Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l), Text(v, style: TextStyle(fontWeight: FontWeight.bold))]));
  @override Widget build(BuildContext context){
    int pendingMonths = 12 - payments.length;
    int pendingAmount = pendingMonths * (widget.student['fee'] as int);
    return Scaffold(
      appBar: AppBar(title: Text(widget.student['name']), backgroundColor: const Color(0xFFFF8C00)),
      body: Stack(children: [
        Column(children: [
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
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                if(isPaid) IconButton(icon: Icon(Icons.share, color: Colors.blue), onPressed: ()=> shareReceipt(m)),
                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: isPaid?Colors.red:Colors.green), onPressed: (){ setState(()=> isPaid? payments.remove(m) : payments[m] = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"); widget.onUpdate(payments); }, child: Text(isPaid?"रद्द":"जमा", style: const TextStyle(color: Colors.white))),
              ]),
            );
          }))
        ]),
        Offstage(child: Screenshot(controller: screenshotController, child: receiptWidget(lastPaidMonth.isEmpty? widget.months[0] : lastPaidMonth)))
      ]),
    );
  }
}
