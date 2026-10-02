import 'dart:io'; import 'dart:convert'; import 'package:flutter/material.dart'; import 'package:shared_preferences/shared_preferences.dart'; import 'package:screenshot/screenshot.dart'; import 'package:share_plus/share_plus.dart'; import 'package:path_provider/path_provider.dart';
void main() async { WidgetsFlutterBinding.ensureInitialized(); runApp(const SaikrupaApp()); }
class SaikrupaApp extends StatelessWidget { const SaikrupaApp({super.key}); @override Widget build(BuildContext context) { return MaterialApp(debugShowCheckedModeBanner: false, home: const HomeScreen()); } }
class HomeScreen extends StatefulWidget { const HomeScreen({super.key}); @override State<HomeScreen> createState() => _HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> {
  int tab=0; String filter="सगळे";
  List<Map<String,dynamic>> students=[];
  final months=["जून","जुलै","ऑगस्ट","सप्टेंबर","ऑक्टोबर","नोव्हेंबर","डिसेंबर","जानेवारी","फेब्रुवारी","मार्च","एप्रिल","मे"];
  final defaultStudents=[{"name":"विहान लुपे","fee":360,"batch":"सकाळ","payments":{}},{"name":"क्रिशा किरमे","fee":400,"batch":"सकाळ","payments":{}},{"name":"अंबरशुमन इतापे","fee":500,"batch":"सकाळ","payments":{}},{"name":"आराध्या यादव","fee":360,"batch":"सकाळ","payments":{}},{"name":"सम्यक भिर्के","fee":360,"batch":"सकाळ","payments":{}},{"name":"श्रेया गादेकर","fee":500,"batch":"सकाळ","payments":{}},{"name":"स्वरा पाटील","fee":360,"batch":"सकाळ","payments":{}},{"name":"स्वरूप पाटील","fee":360,"batch":"सकाळ","payments":{}},{"name":"तेजल पाटील","fee":550,"batch":"संध्याकाळ","payments":{}},{"name":"पूर्वा पाटील","fee":550,"batch":"संध्याकाळ","payments":{}},{"name":"संस्कृती","fee":500,"batch":"संध्याकाळ","payments":{}},{"name":"स्वरांश","fee":400,"batch":"संध्याकाळ","payments":{}}];
  @override void initState(){ super.initState(); load(); }
  Future<void> load() async { final p=await SharedPreferences.getInstance(); final d=p.getString('sc_v5_edit'); if(d!=null){ setState(()=>students=List<Map<String,dynamic>>.from(jsonDecode(d))); } else { setState(()=>students=List<Map<String,dynamic>>.from(defaultStudents)); } }
  Future<void> save() async { final p=await SharedPreferences.getInstance(); p.setString('sc_v5_edit', jsonEncode(students)); }

  Widget logo(double s){ return ClipOval(child: Image.asset('assets/images/logo.png', width: s, height: s, fit: BoxFit.cover, errorBuilder: (c,e,st)=> Container(width:s,height:s, decoration: BoxDecoration(color: const Color(0xFF0A2351), shape: BoxShape.circle, border: Border.all(color: Colors.amber, width:2)), child: const Center(child: Text("SC", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)))))); }

  void showAddEditDialog({Map<String,dynamic>? editStudent, int? editIndex}){
    TextEditingController nameC=TextEditingController(text: editStudent?['name']??"");
    TextEditingController feeC=TextEditingController(text: editStudent?['fee']?.toString()??"400");
    String batch=editStudent?['batch']??"सकाळ";
    showDialog(context: context, builder: (c)=> StatefulBuilder(builder: (c,setD)=> AlertDialog(
      title: Text(editStudent==null? "नवीन विद्यार्थी जोडा" : "विद्यार्थी एडिट करा"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameC, decoration: const InputDecoration(labelText: "नाव", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
        const SizedBox(height:12),
        TextField(controller: feeC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "महिन्याची फी ₹", border: OutlineInputBorder(), prefixIcon: Icon(Icons.currency_rupee))),
        const SizedBox(height:12),
        DropdownButtonFormField<String>(value: batch, decoration: const InputDecoration(labelText: "बॅच", border: OutlineInputBorder()), items: const [DropdownMenuItem(value: "सकाळ", child: Text("सकाळ")), DropdownMenuItem(value: "संध्याकाळ", child: Text("संध्याकाळ"))], onChanged: (v)=>setD(()=>batch=v!))
      ]),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(c), child: const Text("रद्द")),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2351), foregroundColor: Colors.white), onPressed: (){
          if(nameC.text.trim().isEmpty) return;
          setState((){
            var data={"name":nameC.text.trim(), "fee":int.tryParse(feeC.text)??400, "batch":batch, "payments": editStudent?['payments']??{}};
            if(editIndex!=null){ students[editIndex]=data; } else { students.add(data); }
          });
          save(); Navigator.pop(c);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(editIndex!=null? "अपडेट झालं!" : "${nameC.text} जोडलं!"), backgroundColor: Colors.green));
        }, child: Text(editIndex
