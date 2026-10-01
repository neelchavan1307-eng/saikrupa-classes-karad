import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(){ WidgetsFlutterBinding.ensureInitialized(); runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: HomePage())); }

class StudentFee {
  String name, amount, joiningDate, monthPaid, mode, receiptNo;
  StudentFee({required this.name, required this.amount, required this.joiningDate, required this.monthPaid, required this.mode, required this.receiptNo});
}

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState()=> _HomePageState(); }
class _HomePageState extends State<HomePage> {
  String teacherName="Sachin Sir"; List<StudentFee> students=[]; ScreenshotController sc=ScreenshotController();
  TextEditingController searchCtrl=TextEditingController(); String search="";

  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async { final p=await SharedPreferences.getInstance(); setState(()=> teacherName=p.getString('teacher_name')??"Sachin Sir"); }
  Future<void> _saveName(String n) async { final p=await SharedPreferences.getInstance(); await p.setString('teacher_name', n); }

  void _openProfile(){
    var c=TextEditingController(text: teacherName);
    showDialog(context: context, builder: (_)=> AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Teacher Profile", style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFC9A84C), width: 5)),
          child: ClipOval(child: Image.asset('assets/logo.png', fit: BoxFit.cover, errorBuilder: (a,b,d)=> const Icon(Icons.school, size: 80)))),
        const SizedBox(height: 15),
        const Text("SAIKRUPA CLASSES", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        TextField(controller: c, decoration: InputDecoration(labelText: "Teacher Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
      ]),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2342)), onPressed: (){ if(c.text.trim().isEmpty) return; setState(()=> teacherName=c.text.trim()); _saveName(teacherName); Navigator.pop(context); }, child: const Text("SAVE", style: TextStyle(color: Colors.white)))
      ],
    ));
  }

  void _addStudentDialog(){
    var nameCtrl=TextEditingController(); var amtCtrl=TextEditingController(text: "500"); var monthCtrl=TextEditingController(text: DateFormat('MMMM yyyy').format(DateTime.now())); var joinCtrl=TextEditingController(text: "5 Sep 2025"); String mode="Cash";
    showDialog(context: context, builder: (_)=> StatefulBuilder(builder: (context,setD)=> AlertDialog(
      title: const Text("Add Student Fee", style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(child: Column(children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Student Name", border: OutlineInputBorder())), const SizedBox(height: 10),
        TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Amount", border: OutlineInputBorder())), const SizedBox(height: 10),
        TextField(controller: monthCtrl, decoration: const InputDecoration(labelText: "Month Paid", border: OutlineInputBorder())), const SizedBox(height: 10),
        TextField(controller: joinCtrl, decoration: const InputDecoration(labelText: "Joining Date", border: OutlineInputBorder())), const SizedBox(height: 10),
        DropdownButtonFormField(value: mode, items: const [DropdownMenuItem(value: "Cash", child: Text("Cash")), DropdownMenuItem(value: "Online", child: Text("Online"))], onChanged: (v)=> setD(()=> mode=v!)),
      ])),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          onPressed: (){
            if(nameCtrl.text.trim().isEmpty) return;
            String rNo = "SKC-" + DateTime.now().millisecondsSinceEpoch.toString().substring(8);
            final f=StudentFee(name: nameCtrl.text.trim(), amount: amtCtrl.text.trim(), monthPaid: monthCtrl.text.trim(), joiningDate: joinCtrl.text.trim(), mode: mode, receiptNo: rNo);
            Navigator.pop(context);
            _showReceipt(f, isNew: true);
          },
          child: const Text("Save & Receipt")
        )
      ],
    )));
  }

  void _showReceipt(StudentFee s, {bool isNew=false}){
    String paidDate=DateFormat('dd MMM yyyy').format(DateTime.now()); String issued=DateFormat('dd MMM yyyy hh:mm a').format(DateTime.now());
    showDialog(context: context, builder: (_)=> Dialog(insetPadding: const EdgeInsets.all(10), child: SingleChildScrollView(child: Column(children: [
      Screenshot(controller: sc, child: Container(width: 1080, color: const Color(0xFFFFFBF0), child: Stack(children: [
        Positioned.fill(child: Container(margin: const EdgeInsets.all(14), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFC9A84C), width: 2.5)))),
        Padding(padding: const EdgeInsets.fromLTRB(30,25,30,25), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("🌸", style: TextStyle(fontSize: 22)), Image.asset('assets/logo.png', height: 110), const Text("🌸", style: TextStyle(fontSize: 22))]),
          const Text("FEE RECEIPT", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF8B6A2A))),
          const SizedBox(height: 10),
          Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8), color: const Color(0xFF0A2342), child: const Center(child: Text("SAIKRUPA CLASSES - Faith Devotion Education", style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 12)))),
          const SizedBox(height: 20),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 30), child: Column(children: [
            Row(children: [ Expanded(child: _row("Student Name:", s.name, true)), Expanded(child: _row("Paid Date:", paidDate)) ]),
            const SizedBox(height: 12),
            Row(children: [ Expanded(child: _row("Amount:", "Rs. " + s.amount)), Expanded(child: _row("Month Paid:", s.monthPaid)) ]),
            const SizedBox(height: 12),
            Row(children: [ Expanded(child: _row("Joining Date:", s.joiningDate)), Expanded(child: _row("Mode:", s.mode)) ]),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFD9E9FF), borderRadius: BorderRadius.circular(8)), child: Text("Total Paid: Rs. " + s.amount, style: const TextStyle(fontWeight: FontWeight.bold)))),
              const SizedBox(width: 10),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF2E7D32), borderRadius: BorderRadius.circular(20)), child: const Text("Fee Paid", style: TextStyle(color: Colors.white)))
            ]),
          ])),
          const SizedBox(height: 20), const Text("Thank You for your payment!", style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF8B6A2A))),
          const SizedBox(height: 12),
          Container(width: double.infinity, padding: const EdgeInsets.all(6), color: const Color(0xFF0A2342), child: Text("Receipt No: " + s.receiptNo + " | Issued: " + issued, style: const TextStyle(color: Colors.white70, fontSize: 9)))
        ]))
      ]))),
      const SizedBox(height: 12),
      Padding(padding: const EdgeInsets.all(12), child: SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2342), padding: const EdgeInsets.symmetric(vertical: 14)), icon: const Icon(Icons.share, color: Colors.white), label: const Text("IMAGE SHARE", style: TextStyle(color: Colors.white)), onPressed: () async {
        final Uint8List? img=await sc.capture(pixelRatio: 3.0); if(img==null) return; final dir=await getTemporaryDirectory(); final file=await File(dir.path + "/" + s.name + ".png").create(); await file.writeAsBytes(img); if(isNew) setState(()=> students.insert(0,s)); await Share.shareXFiles([XFile(file.path)], text: s.name + " Fee Receipt");
      }))), const SizedBox(height: 10),
    ]))));
  }

  Widget _row(String label, String value, [bool bold=false]) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)), Text(value, style: TextStyle(fontSize: bold?16:14, fontWeight: bold?FontWeight.bold:FontWeight.w500))]);

  @override Widget build(BuildContext context){
    var filtered=students.where((s)=> s.name.toLowerCase().contains(search.toLowerCase())).toList();
    return Scaffold(backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(preferredSize: const Size.fromHeight(70), child: AppBar(backgroundColor: const Color(0xFFFF8C00), title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: ClipOval(child: Image.asset('assets/logo.png', fit: BoxFit.cover))), const SizedBox(width: 10), const Text("SAIKRUPA CLASSES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18))]), Text("Malakapur, Karad - " + teacherName, style: const TextStyle(color: Colors.white70, fontSize: 11)) ]), actions: [IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: _openProfile)], toolbarHeight: 70)),
      body: Column(children: [
        Container(color: Colors.white, padding: const EdgeInsets.all(12), child: Column(children: [
          Row(children: [ _box(students.length.toString(), "Students", const Color(0xFFFFE4B5)), const SizedBox(width: 8), _box("Rs." + students.fold(0, (sum, s)=> sum+ (int.tryParse(s.amount)??0)).toString(), "Jama", const Color(0xFFC8E6C9)), const SizedBox(width: 8), _box("Rs.6000", "Baki", const Color(0xFFFFCDD2)), ]),
          const SizedBox(height: 12),
          TextField(controller: searchCtrl, onChanged: (v)=> setState(()=> search=v), decoration: InputDecoration(hintText: "Search...", prefixIcon: const Icon(Icons.search), filled: true, fillColor: const Color(0xFFEEEEEE), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
        ])),
        Container(color: const Color(0xFF0A2342), padding: const EdgeInsets.symmetric(vertical: 8), child: const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Text("A", style: TextStyle(color: Colors.white)), Text("M", style: TextStyle(color: Colors.white)), Text("J", style: TextStyle(color: Colors.white)), Text("J", style: TextStyle(color: Colors.white)), Text("A", style: TextStyle(color: Colors.white)), Text("S", style: TextStyle(color: Colors.white)), Text("O", style: TextStyle(color: Colors.white)), Text("N", style: TextStyle(color: Colors.white)), Text("D", style: TextStyle(color: Colors.white)), Text("Action", style: TextStyle(color: Colors.white))])),
        Expanded(child: filtered.isEmpty? const Center(child: Text("No students yet")) : ListView.builder(itemCount: filtered.length, itemBuilder: (c,i){
          var s=filtered[i]; return Container(color: Colors.white, padding: const EdgeInsets.all(8), child: Row(children: [Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold))), ElevatedButton(onPressed: ()=> _showReceipt(s), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(60,30)), child: const Text("Receipt", style: TextStyle(fontSize: 10, color: Colors.white))) ]));
        })),
      ]),
      floatingActionButton: FloatingActionButton.extended(onPressed: _addStudentDialog, backgroundColor: const Color(0xFFFF6F00), icon: const Icon(Icons.add, color: Colors.white), label: const Text("Add Student", style: TextStyle(color: Colors.white))),
    );
  }
  Widget _box(String v, String l, Color col)=> Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(10)), child: Column(children: [Text(v, style: const TextStyle(fontWeight: FontWeight.bold)), Text(l, style: const TextStyle(fontSize: 12)) ])));
}
