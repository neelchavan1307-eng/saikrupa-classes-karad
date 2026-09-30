import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const SaikrupaApp());

class SaikrupaApp extends StatelessWidget {
  const SaikrupaApp({super.key});
  @override Widget build(BuildContext context) => const MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
}

class StudentFee {
  String name, amount, joiningDate, monthPaid, mode, receiptNo;
  StudentFee({required this.name, required this.amount, required this.joiningDate, required this.monthPaid, required this.mode, required this.receiptNo});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String teacherName = "Sachin Sir";
  ScreenshotController screenshotController = ScreenshotController();
  List<StudentFee> students = [];

  @override void initState() { super.initState(); _loadTeacher(); }
  Future<void> _loadTeacher() async {
    final p = await SharedPreferences.getInstance();
    setState(()=> teacherName = p.getString('teacher_name')?? "Sachin Sir");
  }
  Future<void> _saveTeacher(String n) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('teacher_name', n);
  }

  // ===== 1. MOTHI PROFILE - FULL SCREEN =====
  void _openBigProfile(){
    var ctrl = TextEditingController(text: teacherName);
    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
      appBar: AppBar(title: const Text("Teacher Profile"), backgroundColor: const Color(0xFF0A2342), foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 20),
          Center(child: Stack(alignment: Alignment.center, children: [
            Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFC9A84C), width: 4), image: const DecorationImage(image: AssetImage('assets/logo.png'), fit: BoxFit.cover))),
            Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFC9A84C), width: 4))),
          ])),
          const SizedBox(height: 20),
          const Text("SAIKRUPA CLASSES", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0A2342))),
          const Text("Faith • Devotion • Education", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          TextField(
            controller: ctrl,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: "Teacher Che Nav",
              hintText: "Ex: Sachin Sir",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              prefixIcon: const Icon(Icons.person, size: 30),
              suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: ()=> ctrl.clear()),
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(width: double.infinity, height: 55, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2342), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: (){
              if(ctrl.text.trim().isEmpty) return;
              setState(()=> teacherName = ctrl.text.trim());
              _saveTeacher(teacherName);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Teacher: $teacherName Save Jhala")));
            },
            child: const Text("SAVE / UPDATE", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          )),
        ]),
      ),
    )));
  }

  // ===== 2. STUDENT EDIT / DELETE =====
  void _editOrDeleteStudent(int index){
    var s = students[index];
    var nameCtrl = TextEditingController(text: s.name);
    var amtCtrl = TextEditingController(text: s.amount);
    var monthCtrl = TextEditingController(text: s.monthPaid);
    var joinCtrl = TextEditingController(text: s.joiningDate);
    String mode = s.mode;

    showDialog(context: context, builder: (_)=> AlertDialog(
      title: Text("Edit / Delete - ${s.name}"),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Student Name", border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Amount", border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: monthCtrl, decoration: const InputDecoration(labelText: "Month Paid", border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: joinCtrl, decoration: const InputDecoration(labelText: "Joining Date", border: OutlineInputBorder())),
        const SizedBox(height: 10),
        DropdownButtonFormField(value: mode, items: const [DropdownMenuItem(value: "Cash", child: Text("Cash")), DropdownMenuItem(value: "Online", child: Text("Online"))], onChanged: (v)=> mode = v!),
      ])),
      actions: [
        TextButton.icon(icon: const Icon(Icons.delete, color: Colors.red), label: const Text("DELETE", style: TextStyle(color: Colors.red)), onPressed: (){
          setState(()=> students.removeAt(index));
          Navigator.pop(context);
        }),
        ElevatedButton(onPressed: (){
          setState((){
            students[index].name = nameCtrl.text.trim();
            students[index].amount = amtCtrl.text.trim();
            students[index].monthPaid = monthCtrl.text.trim();
            students[index].joiningDate = joinCtrl.text.trim();
            students[index].mode = mode;
          });
          Navigator.pop(context);
        }, child: const Text("UPDATE")),
      ],
    ));
  }

  void _addFeeDialog(){
    var nameCtrl = TextEditingController();
    var amtCtrl = TextEditingController(text: "500");
    var monthCtrl = TextEditingController(text: DateFormat('MMMM yyyy').format(DateTime.now()));
    var joinCtrl = TextEditingController(text: "5 Sep 2025");
    String mode = "Cash";
    showDialog(context: context, builder: (_)=> StatefulBuilder(builder: (context, setD)=> AlertDialog(
      title: const Text("Fee Entry"),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Student Name *", border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Amount", border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: monthCtrl, decoration: const InputDecoration(labelText: "Month", border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: joinCtrl, decoration: const InputDecoration(labelText: "Joining Date", border: OutlineInputBorder())),
        const SizedBox(height: 10),
        DropdownButtonFormField(value: mode, items: const [DropdownMenuItem(value: "Cash", child: Text("Cash")), DropdownMenuItem(value: "Online", child: Text("Online"))], onChanged: (v)=> setD(()=> mode = v!)),
      ])),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2342)), onPressed: (){
          if(nameCtrl.text.trim().isEmpty) return;
          final fee = StudentFee(name: nameCtrl.text.trim(), amount: amtCtrl.text.trim(), monthPaid: monthCtrl.text.trim(), joiningDate: joinCtrl.text.trim(), mode: mode, receiptNo: "SKC/${DateTime.now().year}/${DateTime.now().millisecondsSinceEpoch.toString().substring(8,13)}");
          Navigator.pop(context);
          _showReceipt(fee, isNew: true);
        }, child: const Text("Receipt Bana", style: TextStyle(color: Colors.white))),
      ],
    )));
  }

  void _showReceipt(StudentFee s, {bool isNew = false}){
    String paidDate = DateFormat('d MMM yyyy').format(DateTime.now());
    String issued = DateFormat('d MMM yyyy • hh:mm a').format(DateTime.now());
    showDialog(context: context, builder: (_)=> Dialog(insetPadding: const EdgeInsets.all(8), child: SingleChildScrollView(child: Column(children: [
      Screenshot(
        controller: screenshotController,
        child: Container(
          width: 1080, color: const Color(0xFFFFFBF0), padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: const Color(0xFFC9A84C), width: 2.5)),
            child: Column(children: [
              const SizedBox(height: 14),
              // LOGO - Receipt madhe jaeel
              Image.asset('assets/logo.png', height: 95, errorBuilder: (_,__,___)=> const Icon(Icons.school, size: 70, color: Color(0xFF8B6A2A))),
              const SizedBox(height: 6),
              const Text("SAIKRUPA CLASSES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A2342))),
              const SizedBox(height: 8),
              const Text("FEE RECEIPT", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xFF8B6A2A))),
              const SizedBox(height: 10),
              Container(width: double.infinity, color: const Color(0xFF0A2342), padding: const EdgeInsets.symmetric(vertical: 7), child: Center(child: Text("$teacherName • SAIKRUPA CLASSES • Faith • Devotion • Education", style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center))),
              Padding(padding: const EdgeInsets.all(18), child: Column(children: [
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("👤 Student Name:", style: TextStyle(fontSize: 11, color: Colors.black54)), Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 12), Text("💰 Amount: Rs. ${s.amount}"), const SizedBox(height: 12), Text("📅 Joining: ${s.joiningDate}") ])),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("📅 Paid Date: $paidDate"), const SizedBox(height: 12), Text("🗓️ Month: ${s.monthPaid}"), const SizedBox(height: 12), Text("💵 Mode: ${s.mode}") ])),
                ]),
                const SizedBox(height: 18),
                Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14), decoration: BoxDecoration(color: const Color(0xFFD9E9FF), borderRadius: BorderRadius.circular(6)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Total Paid: Rs. ${s.amount}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A2342))), const Text("Balance: Rs. 0")])),
              ])),
              Container(width: double.infinity, color: const Color(0xFF0A2342), padding: const EdgeInsets.all(7), child: Text("Receipt No: ${s.receiptNo} | Teacher: $teacherName | Issued: $issued", style: const TextStyle(color: Colors.white, fontSize: 8.5), textAlign: TextAlign.center)),
            ]),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: SizedBox(width: double.infinity, child: ElevatedButton.icon(icon: const Icon(Icons.share), label: Text("${s.name} la Logo sahit Share"), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2342), padding: const EdgeInsets.symmetric(vertical: 14)), onPressed: () async {
        final Uint8List? img = await screenshotController.capture();
        if(img==null) return;
        final dir = await getTemporaryDirectory();
        final file = await File('${dir.path}/${s.name}_receipt.png').create();
        await file.writeAsBytes(img);
        if(isNew) setState(()=> students.insert(0, s));
        await Share.shareXFiles([XFile(file.path)], text: "${s.name} - Fee Receipt by $teacherName - Saikrupa Classes");
      }))),
      const SizedBox(height: 10),
    ]))));
  }

  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saikrupa Classes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A2342),
        actions: [
          IconButton(icon: const Icon(Icons.account_circle, size: 38), onPressed: _openBigProfile, tooltip: "Mothi Profile"),
        ],
      ),
      body: students.isEmpty? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.school, size: 90, color: Color(0xFFC9A84C)),
        const SizedBox(height: 12),
        Text("Teacher: $teacherName", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        ElevatedButton.icon(onPressed: _openBigProfile, icon: const Icon(Icons.person), label: const Text("MOTHI PROFILE BAGHA / EDIT KARA")),
      ])) : ListView.builder(itemCount: students.length, itemBuilder: (c,i)=> Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: ListTile(
        onTap: ()=> _showReceipt(students[i]),
        onLongPress: ()=> _editOrDeleteStudent(i),
        leading: CircleAvatar(child: Text(students[i].name[0].toUpperCase())),
        title: Text(students[i].name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Rs.${students[i].amount} | ${students[i].monthPaid} | By $teacherName"),
        trailing: PopupMenuButton(onSelected: (v){ if(v=='edit') _editOrDeleteStudent(i); else setState(()=> students.removeAt(i)); }, itemBuilder: (_)=> const [PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit), SizedBox(width:8), Text("Edit")])), PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width:8), Text("Delete", style: TextStyle(color: Colors.red))]))]),
      ))),
      floatingActionButton: FloatingActionButton.extended(onPressed: _addFeeDialog, backgroundColor: const Color(0xFF0A2342), foregroundColor: Colors.white, icon: const Icon(Icons.add), label: const Text("Fee Add Kara")),
    );
  }
}
