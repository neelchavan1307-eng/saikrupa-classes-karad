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
  List<bool> months; // 12 months J to D

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
    String? d = p.getString('students_v2');
    if(d!= null){ List l = jsonDecode(d); setState(()=> students = l.map((e)=> Student.fromJson(e)).toList()); }
  }
  saveData() async {
    final p = await SharedPreferences.getInstance();
    p.setString('students_v2', jsonEncode(students.map((e)=>e.toJson()).toList()));
  }

  void addStudentDialog(){
    String name="", std="", phone=""; int fee=1000;
    showDialog(context: context, builder: (c)=> AlertDialog(
      title: Text('Navin Vidyarthi Add Kara'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(decoration: InputDecoration(labelText: 'Nav - Ex: Vihan Tope'), onChanged: (v)=>name=v),
        TextField(decoration: InputDecoration(labelText: 'Iyatta - Ex: 10th'), onChanged: (v)=>std=v),
        TextField(decoration: InputDecoration(labelText: 'Mobile Number'), keyboardType: TextInputType.phone, onChanged: (v)=>phone=v),
        TextField(decoration: InputDecoration(labelText: 'Mahinyachi Fee - Ex: 1000'), keyboardType: TextInputType.number, controller: TextEditingController(text: "1000"), onChanged: (v)=> fee=int.tryParse(v)??1000),
      ]),
      actions: [TextButton(onPressed: ()=>Navigator.pop(c), child: Text('Cancel')), ElevatedButton(onPressed: (){
        if(name.isNotEmpty){ setState(()=> students.add(Student(name: name, std: std, phone: phone, monthlyFee: fee, months: List.filled(12, false)))); saveData(); Navigator.pop(c); }
      }, child: Text('Add'))],
    ));
  }

  void sendWhatsAppReport() async {
    var pending = students.where((s)=> s.balance > 0).toList();
    if(pending.isEmpty) return;
    String msg = "📚 *SAIKRUPA CLASSES - Fee Report* 📚\n\n";
    for(var s in pending){
      msg += "👉 ${s.name} (${s.std}) - Baki: ₹${s.balance} - Paid: ${s.paidCount}/12 mahine\n";
    }
    msg += "\n- Saikrupa Classes, Karad";
    final url = Uri.parse("https://wa.me/?text=${Uri.encodeComponent(msg)}");
    if(await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override Widget build(BuildContext context){
    int totalStudents = students.length;
    int totalPaid = students.fold(0, (sum, s)=> sum + s.paidAmount);
    int totalBalance = students.fold(0, (sum, s)=> sum + s.balance);
    int unpaidStudents = students.where((s)=> s.balance > 0).length;

    List<Student> filtered = students.where((s)=> s.name.toLowerCase().contains(search.toLowerCase()) || s.phone.contains(search)).toList();

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(title: Text('SAIKRUPA CLASSES', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 1),
      body: SingleChildScrollView(
        child: Column(children: [
          // Top Header
          Container(color: Colors.white, padding: EdgeInsets.all(16), child: Column(children: [
            Text('SAIKRUPA CLASSES', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Row(children: [
              Expanded(child: _topCard(totalStudents.toString(), "एकूण विद्यार्थी", Colors.orange.shade100)),
              SizedBox(width: 8),
              Expanded(child: _topCard("₹$totalPaid", "एकूण जमा", Colors.green.shade100)),
            ]),
            SizedBox(height: 8),
            Row(children: [
              Expanded(child: _topCard("₹$totalBalance", "एकूण बाकी (BALANCE)", Colors.red.shade100)),
              SizedBox(width: 8),
              Expanded(child: _topCard("$unpaidStudents विद्यार्थी", "फी बाकी असलेले", Colors.yellow.shade100)),
            ]),
            SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: sendWhatsAppReport, icon: Icon(Icons.message), label: Text('WhatsApp Report पाठवा'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white))),
          ])),
          SizedBox(height: 8),
          // Search
          Container(color: Colors.white, padding: EdgeInsets.all(8), child: TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'नाव किंवा फोन नंबर ने शोधा...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), onChanged: (v)=>setState(()=> search=v))),
          // Table Header
          Container(color: Color(0xFF1A1A2E), padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8), child: Row(children: [
            Expanded(flex: 3, child: Text('नाव', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
            Expanded(flex: 4, child: Row(children: monthNames.map((m)=> Expanded(child: Center(child: Text(m, style: TextStyle(color: Colors.white70, fontSize: 11))))).toList())),
            Expanded(child: Text('PAID', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
            Expanded(child: Text('BALANCE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
            Expanded(child: Text('ACTION', style: TextStyle(color: Colors.white, fontSize: 10))),
          ])),
          // Student List
         ...filtered.map((s){
            int idx = students.indexOf(s);
            return Container(
              color: Colors.white,
              margin: EdgeInsets.only(bottom: 1),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Row(children: [
                Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('${s.std} - ₹${s.monthlyFee}/m', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ])),
                Expanded(flex: 4, child: Row(children: List.generate(12, (mi){
                  bool isPaid = s.months[mi];
                  return Expanded(child: InkWell(onTap: (){
                    setState(()=> students[idx].months[mi] =!students[idx].months[mi]); saveData();
                  }, child: Container(margin: EdgeInsets.all(1), height: 22, decoration: BoxDecoration(color: isPaid? Colors.green : Colors.red.shade400, borderRadius: BorderRadius.circular(4)), child: Icon(isPaid? Icons.check : Icons.close, size: 12, color: Colors.white))));
                }))),
                Expanded(child: Text('₹${s.paidAmount}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green))),
                Expanded(child: Text('₹${s.balance}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red))),
                Expanded(child: Row(children: [
                  InkWell(onTap: (){ setState(()=> students.removeAt(idx)); saveData(); }, child: Icon(Icons.delete, size: 16, color: Colors.grey)),
                  SizedBox(width: 4),
                  InkWell(onTap: () async {
                    String msg = "Namaskar 🙏 ${s.name} (${s.std})\nPaid: ₹${s.paidAmount} (${s.paidCount}/12)\nBaki: ₹${s.balance}\n- Saikrupa Classes";
                    final url = Uri.parse("https://wa.me/91${s.phone}?text=${Uri.encodeComponent(msg)}");
                    if(await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
                  }, child: Icon(Icons.message, size: 16, color: Colors.green)),
                ])),
              ]),
            );
          }).toList(),
          SizedBox(height: 80),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: addStudentDialog, label: Text('Add Student'), icon: Icon(Icons.add), backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
    );
  }

  Widget _topCard(String val, String title, Color col){
    return Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(10)), child: Column(children: [Text(val, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), SizedBox(height: 4), Text(title, style: TextStyle(fontSize: 10), textAlign: TextAlign.center)]));
  }
}
