// PART 1 START - Saikrupa Classes Karad
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const SaikrupaApp());

const String phNo = "9822001122";
const String appName = "SAIKRUPA CLASSES, KARAD";

class Student {
  String name;
  String phone;
  int fee;
  List<String> paid;
  Student({required this.name, required this.phone, required this.fee, required this.paid});
  Map<String,dynamic> toJson() => {"name":name,"phone":phone,"fee":fee,"paid":paid};
  factory Student.fromJson(Map<String,dynamic> j) => Student(name:j["name"],phone:j["phone"]??"",fee:j["fee"],paid:List<String>.from(j["paid"]??[]));
}

class SaikrupaApp extends StatelessWidget {
  const SaikrupaApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner:false, title:appName, theme:ThemeData(primarySwatch:Colors.indigo), home:const HomePage());
  }
}

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState()=> _HomePageState(); }

class _HomePageState extends State<HomePage> {
  List<Student> students=[];
  final List<String> months=["J","F","M","A","M","J","J","A","S","O","N","D"];
  final List<String> monthNames=["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];

  @override void initState(){ super.initState(); _load(); }

  Future<void> _load() async {
    final p=await SharedPreferences.getInstance();
    final s=p.getString("students");
    if(s!=null){ setState(()=> students=(jsonDecode(s) as List).map((e)=>Student.fromJson(e)).toList()); }
  }
  Future<void> _save() async {
    final p=await SharedPreferences.getInstance();
    p.setString("students", jsonEncode(students.map((e)=>e.toJson()).toList()));
  }

  Future<void> _share(Student s,String mn,int fee,String date,String rNo) async{
    final msg="*$appName - Digital Receipt*\n\nReceipt No: $rNo\nDate: $date\nStudent: ${s.name}\nPhone: ${s.phone}\nMonth: $mn 2025\nAmount: Rs $fee/- PAID\n\nThank you!\n$appName - $phNo";
    await Share.share(msg);
  }
  Future<void> _waBal(Student s) async{
    int bal=(12-s.paid.length)*s.fee;
    final msg='Hello ${s.name}, Your fee balance Rs $bal is pending at $appName. Please pay soon. Contact: $phNo';
    await Share.share(msg);
  }
// PART 1 END - आता PART 2 खाली Paste करा// PART 2 START - याला PART 1 च्या खाली Paste करा
  void _addStudentDialog(){
    final n=TextEditingController(); final ph=TextEditingController(); final f=TextEditingController(text:"1000");
    showDialog(context:context, builder:(_)=>AlertDialog(title:const Text("Add Student"), content:Column(mainAxisSize:MainAxisSize.min, children:[
      TextField(controller:n, decoration:const InputDecoration(labelText:"Name")),
      TextField(controller:ph, decoration:const InputDecoration(labelText:"Phone (10 digit)"), keyboardType:TextInputType.phone),
      TextField(controller:f, decoration:const InputDecoration(labelText:"Monthly Fee"), keyboardType:TextInputType.number),
    ]), actions:[TextButton(onPressed:()=>Navigator.pop(context), child:const Text("Cancel")), ElevatedButton(onPressed:(){ if(n.text.isNotEmpty){ setState(()=>students.add(Student(name:n.text, phone:ph.text, fee:int.tryParse(f.text)??1000, paid:[]))); _save(); Navigator.pop(context);} }, child:const Text("Add"))]));
  }

  void _showReceipt(Student s, int monthIndex){
    final now=DateTime.now();
    final rNo="SK${now.millisecondsSinceEpoch.toString().substring(7)}";
    final date="${now.day}/${now.month}/${now.year}";
    final mn=monthNames[monthIndex];
    showDialog(context:context, builder:(_)=>AlertDialog(title:const Text("Receipt"), content:Column(mainAxisSize:MainAxisSize.min, crossAxisAlignment:CrossAxisAlignment.start, children:[
      Text("Receipt: $rNo"), Text("Date: $date"), Text("Student: ${s.name}"), Text("Month: $mn"), Text("Amount: Rs ${s.fee} PAID"), const SizedBox(height:10), const Text("SAIKRUPA CLASSES, KARAD", style:TextStyle(fontWeight:FontWeight.bold)),
    ]), actions:[
      TextButton(onPressed:()=>Navigator.pop(context), child:const Text("Close")),
      ElevatedButton.icon(icon:const Icon(Icons.share), label:const Text("WhatsApp / Share"), onPressed:()=>_share(s,mn,s.fee,date,rNo))
    ]));
  }

  @override Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(title:const Text(appName), actions:[IconButton(icon:const Icon(Icons.add), onPressed:_addStudentDialog)]),
      body:students.isEmpty? const Center(child:Text("No Students - Click + to Add")) : ListView.builder(itemCount:students.length, itemBuilder:(c,i){
        final s=students[i];
        return Card(margin:const EdgeInsets.all(6), child:ListTile(
          title:Text(s.name, style:const TextStyle(fontWeight:FontWeight.bold)),
          subtitle:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
            Text("Phone: ${s.phone} | Fee: ${s.fee}"),
            const SizedBox(height:6),
            Wrap(spacing:4, children:List.generate(12, (m){
              final isPaid=s.paid.contains(months[m]);
              return GestureDetector(
                onTap:(){
                  setState((){
                    if(isPaid) s.paid.remove(months[m]); else { s.paid.add(months[m]); _showReceipt(s,m); }
                  }); _save();
                },
                child:CircleAvatar(radius:14, backgroundColor:isPaid?Colors.green:Colors.grey[300], child:Text(months[m], style:TextStyle(fontSize:10, color:isPaid?Colors.white:Colors.black))),
              );
            }))
          ]),
          trailing:IconButton(icon:const Icon(Icons.message, color:Colors.green), onPressed:()=>_waBal(s)),
        ));
      }),
    );
  }
}
// PART 2 END - आता Commit करा
