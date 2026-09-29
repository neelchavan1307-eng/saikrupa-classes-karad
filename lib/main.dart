import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saikrupa Classes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true),
      home: HomePage(),
    );
  }
}

class Student {
  String name, std, phone;
  int monthlyFee;
  List<bool> months;
  Student({required this.name, required this.std, required this.phone, required this.monthlyFee, required this.months});
  int get paidCount => months.where((m)=>m).length;
  int get paidAmount => paidCount * monthlyFee;
  int get totalFee => monthlyFee * 12;
  int get balance => totalFee - paidAmount;
  Map toJson() => {'name': name, 'std': std, 'phone': phone, 'monthlyFee': monthlyFee, 'months': months};
  factory Student.fromJson(Map m) => Student(name: m['name'], std: m['std'], phone: m['phone'], monthlyFee: m['monthlyFee'], months: List<bool>.from(m['months']));
}

class HomePage extends StatefulWidget { @override _HomePageState createState() => _HomePageState(); }

class _HomePageState extends State<HomePage> {
  List<Student> students = [];
  String search = "";
  final List<String> monthNames = ["J","F","M","A","M","J","J","A","S","O","N","D"];

  @override void initState(){ super.initState(); loadData(); }
  loadData() async {
    final p = await SharedPreferences.getInstance();
    String? d = p.getString('students_v3');
    if(d!= null){ List l = jsonDecode(d); setState(()=> students = l.map((e)=> Student.fromJson(e)).toList()); }
  }
  saveData() async {
    final p = await SharedPreferences.getInstance();
    p.setString('students_v3', jsonEncode(students.map((e)=>e.toJson()).toList()));
  }

  void addStudentDialog(){
    String name="", std="", phone=""; int fee=500;
    showDialog(context: context, builder: (c)=> AlertDialog(
      title: Text('Navin Vidyarthi'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(decoration: InputDecoration(labelText: 'Nav'), onChanged: (v)=>name=v),
        TextField(decoration: InputDecoration(labelText: 'Iyatta'), onChanged: (v)=>std=v),
        TextField(decoration: InputDecoration(labelText: 'Mobile'), keyboardType: TextInputType.phone, onChanged: (v)=>phone=v),
        TextField(decoration: InputDecoration(labelText: 'Monthly Fee'), keyboardType: TextInputType.number, controller: TextEditingController(text: "500"), onChanged: (v)=> fee=int.tryParse(v)??500),
      ]),
      actions: [TextButton(onPressed: ()=>Navigator.pop(c), child: Text('Cancel')), ElevatedButton(onPressed: (){
        if(name.isNotEmpty){ setState(()=> students.add(Student(name: name, std: std, phone: phone, monthlyFee: fee, months: List.filled(12, false)))); saveData(); Navigator.pop(c); }
      }, child: Text('Add'))],
    ));
  }

  @override Widget build(BuildContext context){
    int totalPaid = students.fold(0, (sum, s)=> sum + s.paidAmount);
    int totalBalance = students.fold(0, (sum, s)=> sum + s.balance);
    int unpaidStudents = students.where((s)=> s.balance > 0).length;
    List<Student> filtered = students.where((s)=> s.name.toLowerCase().contains(search.toLowerCase())).toList();
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      body: SafeArea(child: SingleChildScrollView(
        child: Column(children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Column(children: [
              Row(children: [
                CircleAvatar(radius: 28, backgroundColor: Colors.orange.shade100, child: Text("SC", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.deepOrange))),
                SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('SAIKRUPA CLASSES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('Karad - Vidya Vinayen Shobhate', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  SizedBox(height: 2),
                  Text('Malakapur, Karad | 90220022XX', style: TextStyle(fontSize: 11, color: Colors.black87)),
                ])),
              ]),
              SizedBox(height: 14),
              Text('SAIKRUPA CLASSES', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1)),
              SizedBox(height: 10),
              Row(children: [
                Expanded(child: _topCard("${students.length}", "एकूण विद्यार्थी", Color(0xFFFFE0B2))),
                SizedBox(width: 8),
                Expanded(child: _topCard("₹$totalPaid", "एकूण जमा", Color(0xFFC8E6C9))),
              ]),
              SizedBox(height: 8),
              Row(children: [
                Expanded(child: _topCard("₹$totalBalance", "एकूण बाकी", Color(0xFFFFCDD2))),
                SizedBox(width: 8),
                Expanded(child: _topCard("$unpaidStudents विद्यार्थी", "फी बाकी असलेले", Color(0xFFFFF9C4))),
              ]),
              SizedBox(height: 12),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () async {
                var pending = students.where((s)=> s.balance > 0).toList();
                String msg = "SAIKRUPA CLASSES - Fee Report\n\n";
                for(var s in pending){ msg += "${s.name} - Baki: ₹${s.balance}\n"; }
                final url = Uri.parse("https://wa.me/?text=${Uri.encodeComponent(msg)}");
                if(await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
              }, icon: Icon(Icons.chat_bubble, size: 18), label: Text('WhatsApp Report पाठवा'), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2E7D32), foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))))),
            ]),
          ),
          SizedBox(height: 8),
          Container(color: Colors.white, padding: EdgeInsets.all(10), child: TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'नाव किंवा फोन नंबर ने शोधा...', contentPadding: EdgeInsets.symmetric(vertical: 10), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), onChanged: (v)=>setState(()=> search=v))),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(children: [
              Container(color: Color(0xFF1E1E2F), width: 700, padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Row(children: [
                SizedBox(width: 140, child: Text('नाव', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                ...monthNames.map((m)=> Container(width: 32, margin: EdgeInsets.symmetric(horizontal: 2), child: Center(child: Text(m, style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold))))),
                SizedBox(width: 60, child: Text('PAID', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                SizedBox(width: 70, child: Text('BALANCE', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                SizedBox(width: 60, child: Text('ACTION', style: TextStyle(color: Colors.white, fontSize: 12))),
              ])),
              ...filtered.map((s){
                int idx = students.indexOf(s);
                return Container(color: Colors.white, width: 700, margin: EdgeInsets.only(bottom: 1), padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8), child: Row(children: [
                  SizedBox(width: 140, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), 
                    Text('${s.std} - ₹${s.monthlyFee}/m', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ])),
                  ...List.generate(12, (mi){
                    bool isPaid = s.months[mi];
                    return GestureDetector(onTap: (){ setState(()=> students[idx].months[mi] = !students[idx].months[mi]); saveData(); }, 
                    child: Container(width: 32, height: 28, margin: EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: isPaid? Colors.green : Color(0xFFE57373), borderRadius: BorderRadius.circular(6)), child: Center(child: Icon(isPaid? Icons.check : Icons.close, size: 16, color: Colors.white))));
                  }),
                  SizedBox(width: 60, child: Text('₹${s.paidAmount}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green))),
                  SizedBox(width: 70, child: Text('₹${s.balance}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red))),
                  SizedBox(width: 60, child: Row(children: [
                    InkWell(onTap: (){ setState(()=> students.removeAt(idx)); saveData(); }, child: Icon(Icons.delete, size: 20, color: Colors.grey)),
                    SizedBox(width: 8),
                    InkWell(onTap: () async {
                      String msg = "Namaskar ${s.name}\nPaid: ₹${s.paidAmount}\nBaki: ₹${s.balance}";
                      final url = Uri.parse("https://wa.me/91${s.phone}?text=${Uri.encodeComponent(msg)}");
                      if(await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
                    }, child: Icon(Icons.message, size: 20, color: Colors.green)),
                  ])),
                ]));
              }).toList(),
            ]),
          ),
          SizedBox(height: 100),
        ]),
      )),
      floatingActionButton: FloatingActionButton.extended(onPressed: addStudentDialog, label: Text('Add Student'), icon: Icon(Icons.add), backgroundColor: Color(0xFFFF5722), foregroundColor: Colors.white),
    );
  }

  Widget _topCard(String val, String title, Color col){
    return Container(padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8), decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(12)), child: Column1
