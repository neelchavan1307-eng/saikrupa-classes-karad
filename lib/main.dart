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
        Container(width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFC9A84C), width: 5), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)]),
          child: ClipOval(child: Image.asset('assets/logo.png', fit: BoxFit.cover, errorBuilder: (_,__,___)=> const Icon(Icons.school, size: 80, color: Color(0xFF8B6A2A))))),
        const SizedBox(height: 15), const Text("SAIKRUPA CLASSES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 20),
        TextField(controller: c, decoration: InputDecoration(labelText: "Teacher Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.person))),
      ]),
      actions: [ TextButton(onPressed: ()=> Navigator.pop(context), child: const Text("Cancel")), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2342)), onPressed: (){ if(c.text.trim().isEmpty) return; setState(()=> teacherName=c.text.trim()); _saveName(teacherName); Navigator.pop(context); }, child: const Text("SAVE", style: TextStyle(color: Colors.white)))],
    ));
  }

  void _addStudentDialog(){
    var nameCtrl=TextEditingController(); var amtCtrl=TextEditingController(text: "500"); var monthCtrl=TextEditingController(text: DateFormat('MMMM yyyy').format(DateTime.now())); var joinCtrl=TextEditingController(text: "5 Sep 2025"); String mode="Cash";
    showDialog(context: context, builder: (_)=> StatefulBuilder(builder: (context,setD)=> AlertDialog(
      title: const Text("Add Student Fee", style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(child: Column(children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Student Name *", border: OutlineInputBorder())), const SizedBox(height: 10),
        TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Amount", border: OutlineInputBorder())), const SizedBox(height: 10),
        TextField(controller: monthCtrl, decoration: const InputDecoration(labelText: "Month Paid", border: OutlineInputBorder())), const SizedBox(height: 10),
        TextField(controller: joinCtrl, decoration: const InputDecoration(labelText: "Joining Date", border: OutlineInputBorder())), const SizedBox(height: 10),
        DropdownButtonFormField(value: mode, items: const [DropdownMenuItem(value: "Cash", child: Text("Cash")), DropdownMenuItem(value: "Online", child: Text("Online"))], onChanged: (v)=> setD(()=> mode=v!)),
      ])),
      actions: [ TextButton(onPressed: ()=> Navigator.pop(context), child: const Text("Cancel")), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), onPressed: (){ if(nameCtrl.text.trim().isEmpty) return; final f=StudentFee(name: nameCtrl.text.trim(), amount: amtCtrl.text.trim(), monthPaid: monthCtrl.text.trim(), joiningDate: joinCtrl.text.trim(), mode: mode, receiptNo: "SKC/${DateTime.now().year}/${DateTime.now
