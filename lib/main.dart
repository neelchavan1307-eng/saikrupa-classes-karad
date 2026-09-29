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
      theme: ThemeData(primarySwatch: Colors.deepOrange, useMaterial3: true),
      home: HomePage(),
    );
  }
}

class Student {
  String name; String std; String phone; int totalFee; int paidFee;
  Student({required this.name, required this.std, required this.phone, required this.totalFee, required this.paidFee});
  int get remaining => totalFee - paidFee;
  Map toJson() => {'name': name, 'std': std, 'phone': phone, 'totalFee': totalFee, 'paidFee': paidFee};
  factory Student.fromJson(Map m) => Student(name: m['name'], std: m['std'], phone: m['phone'], totalFee: m['totalFee'], paidFee: m['paidFee']);
}

class HomePage extends StatefulWidget { @override _HomePageState createState() => _HomePageState(); }

class _HomePageState extends State<HomePage> {
  List<Student> students = []; int _index = 0; String searchQuery = "";
  @override void initState() { super.initState(); loadData(); }
  loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('students');
    if (data!= null) { List list = jsonDecode(data); setState(() { students = list.map((e) => Student.fromJson(e)).toList(); }); }
  }
  saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('students', jsonEncode(students.map((e) => e.toJson()).toList()));
  }
  void openWhatsApp(Student s) async {
    String msg = "Namaskar 🙏\nSaikrupa Classes kadun sandesh.\n\nVidyarthi: ${s.name} (${s.std})\nTotal Fee: ${s.totalFee}\nJama: ${s.paidFee}\nBaki Fee: ${s.remaining}\n\nKrupaya lavkarat lavkar jama kara.\n- Saikrupa Classes";
    final url = Uri.parse("https://wa.me/91${s.phone}?text=${Uri.encodeComponent(msg)}");
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }
  void addStudentDialog({Student? editStudent, int? editIndex}) {
    String name = editStudent?.name?? "", std = editStudent?.std?? "", phone = editStudent?.phone?? ""; int fee = editStudent?.totalFee?? 0;
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text(editStudent == null? 'Navin Vidyarthi' : 'Edit Kara'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(decoration: InputDecoration(labelText: 'Nav'), controller: TextEditingController(text: name), onChanged: (v)=>name=v),
        TextField(decoration: InputDecoration(labelText: 'Iyatta'), controller: TextEditingController(text: std), onChanged: (v)=>std=v),
        TextField(decoration: InputDecoration(labelText: 'Mobile'), keyboardType: TextInputType.phone, controller: TextEditingController(text: phone), onChanged: (v)=>phone=v),
        TextField(decoration: InputDecoration(labelText: 'Total Fee'), keyboardType: TextInputType.number, controller: TextEditingController(text: fee==0?"":fee.toString()), onChanged: (v)=>fee=int.tryParse(v)??0),
      ])),
      actions: [TextButton(onPressed: ()=>Navigator.pop(c), child: Text('Cancel')), ElevatedButton(onPressed: (){ if(name.isNotEmpty){ setState((){ if(editIndex!=null) students[editIndex] = Student(name: name, std: std, phone: phone, totalFee: fee, paidFee: editStudent!.paidFee); else students.add(Student(name: name, std: std, phone: phone, totalFee: fee, paidFee: 0)); }); saveData(); Navigator.pop(c); } }, child: Text(editStudent==null?'Add':'Save'))],
    ));
  }
  void payFeeDialog(int i){ int pay=0;
    showDialog(context: context, builder: (c)=>AlertDialog(
      title: Text("${students[i].name} - Fee Bhara"),
      content: TextField(decoration: InputDecoration(labelText: 'Rakkam'), keyboardType: TextInputType.number, onChanged: (v)=>pay=int.tryParse(v)??0),
      actions: [TextButton(onPressed: ()=>Navigator.pop(c), child: Text('Cancel')), ElevatedButton(onPressed: (){ setState((){ students[i].paidFee += pay; if(students[i].paidFee > students[i].totalFee) students[i].paidFee = students[i].totalFee; }); saveData(); Navigator.pop(c); }, child: Text('Jama Kara'))],
    ));
  }
  @override Widget build(BuildContext context){
    int totalCollection = students.fold(0, (s,e)=>s+e.paidFee);
    int totalPending = students.fold(0, (s,e)=>s+e.remaining);
    List<Student> filtered = students.where((s) => s.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(title: Text('Saikrupa Classes'), backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
      body: _index==0? SingleChildScrollView(padding: EdgeInsets.all(16), child: Column(children: [
        Container(padding: EdgeInsets.all(20), width: double.infinity, decoration: BoxDecoration(color: Colors.deepOrange, borderRadius: BorderRadius.circular(16)), child: Column(children: [Text('Saikrupa Classes', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), Text('Vidya Vinayen Shobhate 🙏', style: TextStyle(color: Colors.white))])),
        SizedBox(height: 20),
        Row(children: [Expanded(child: _dashCard('Vidyarthi', '$students.length', Icons.people, Colors.blue)), SizedBox(width:10), Expanded(child: _dashCard('Jama', '₹$totalCollection', Icons.check_circle, Colors.green))]),
        SizedBox(height:10), _dashCard('Baki Fee', '₹$totalPending', Icons.pending, Colors.red, full:true),
      ])) : Column(children: [
        Padding(padding: EdgeInsets.all(8), child: TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Navane shodha...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), onChanged: (v)=>setState(()=>searchQuery=v))),
        Expanded(child: ListView.builder(itemCount: filtered.length, itemBuilder: (c,i){
          int realIndex = students.indexOf(filtered[i]);
          return Card(margin: EdgeInsets.all(6), child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.deepOrange.shade100, child: Text(filtered[i].name.isNotEmpty?filtered[i].name[0].toUpperCase():"S")),
            title: Text(filtered[i].name, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Iyatta: ${filtered[i].std} | Baki: ₹${filtered[i].remaining}"),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: Icon(Icons.message, color: Colors.green), onPressed: ()=>openWhatsApp(filtered[i])),
              IconButton(icon: Icon(Icons.currency_rupee), onPressed: ()=>payFeeDialog(realIndex)),
            ]),
            onLongPress: (){ showDialog(context: context, builder: (c)=>AlertDialog(title: Text('Delete?'), content: Text('${filtered[i].name} la kadhu ka?'), actions: [TextButton(onPressed: ()=>Navigator.pop(c), child: Text('Nahi')), TextButton(onPressed: (){setState(()=>students.removeAt(realIndex)); saveData(); Navigator.pop(c);}, child: Text('Ho'))])); },
          ));
        }))
      ]),
      floatingActionButton: _index==1? FloatingActionButton(onPressed: ()=>addStudentDialog(), backgroundColor: Colors.deepOrange, child: Icon(Icons.add)) : null,
      bottomNavigationBar: BottomNavigationBar(currentIndex: _index, onTap: (v)=>setState(()=>_index=v), selectedItemColor: Colors.deepOrange, items: [BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'), BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Vidyarthi')]),
    );
  }
  Widget _dashCard(String t, String v, IconData ic, Color c, {bool full=false}){
    return Container(width: full?double.infinity:null, padding: EdgeInsets.all(16), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: c.withOpacity(0.3))), child: Column(children: [Icon(ic, color: c, size: 32), SizedBox(height:8), Text(t), Text(v, style: TextStyle(fontSize:20, fontWeight: FontWeight.bold, color: c))] ));
  }
}
