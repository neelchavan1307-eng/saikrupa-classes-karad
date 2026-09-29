import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saikrupa Classes - Karad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepOrange, useMaterial3: true),
      home: HomePage(),
    );
  }
}

class Student {
  String name; String std; String phone; int totalFee; int paidFee;
  Student({required this.name, required this.std, required this.phone, required this.totalFee, required this.paidFee});
  Map toJson() => {'name':name,'std':std,'phone':phone,'totalFee':totalFee,'paidFee':paidFee};
  factory Student.fromJson(Map j) => Student(name:j['name'], std:j['std'], phone:j['phone'], totalFee:j['totalFee'], paidFee:j['paidFee']);
  int get remaining => totalFee - paidFee;
}

class HomePage extends StatefulWidget { @override _HomePageState createState() => _HomePageState(); }

class _HomePageState extends State<HomePage> {
  List<Student> students = [];
  int _index = 0;

  @override void initState() { super.initState(); loadData(); }
  loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('students');
    if (data != null) {
      List list = jsonDecode(data);
      setState(() { students = list.map((e) => Student.fromJson(e)).toList(); });
    }
  }
  saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('students', jsonEncode(students.map((e) => e.toJson()).toList()));
  }

  void addStudentDialog() {
    String name='', std='', phone=''; int fee=0;
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text('Navin Vidyarthi Add Kara'),
      content: SingleChildScrollView(child: Column(children: [
        TextField(decoration: InputDecoration(labelText: 'Nav'), onChanged: (v)=>name=v),
        TextField(decoration: InputDecoration(labelText: 'Iyatta (eg 10th)'), onChanged: (v)=>std=v),
        TextField(decoration: InputDecoration(labelText: 'Mobile'), keyboardType: TextInputType.phone, onChanged: (v)=>phone=v),
        TextField(decoration: InputDecoration(labelText: 'Total Fee'), keyboardType: TextInputType.number, onChanged: (v)=>fee=int.tryParse(v)??0),
      ])),
      actions: [ TextButton(onPressed: ()=>Navigator.pop(c), child: Text('Cancel')), ElevatedButton(onPressed: (){
        if(name.isNotEmpty){ setState((){ students.add(Student(name:name, std:std, phone:phone, totalFee:fee, paidFee:0)); }); saveData(); Navigator.pop(c); }
      }, child: Text('Add'))],
    ));
  }

  void payFeeDialog(int i) {
    int pay=0;
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text('${students[i].name} - Fee Bhara'),
      content: TextField(decoration: InputDecoration(labelText: 'Rakkam'), keyboardType: TextInputType.number, onChanged: (v)=>pay=int.tryParse(v)??0),
      actions: [ TextButton(onPressed: ()=>Navigator.pop(c), child: Text('Cancel')), ElevatedButton(onPressed: (){
        setState((){ students[i].paidFee += pay; if(students[i].paidFee > students[i].totalFee) students[i].paidFee = students[i].totalFee; }); saveData(); Navigator.pop(c);
      }, child: Text('Jama Kara'))],
    ));
  }

  @override Widget build(BuildContext context) {
    int totalCollection = students.fold(0, (s,e)=>s+e.paidFee);
    int totalPending = students.fold(0, (s,e)=>s+e.remaining);
    return Scaffold(
      appBar: AppBar(title: Text('Saikrupa Classes - Karad'), backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
      body: _index==0 ? DashboardView(totalCollection: totalCollection, totalPending: totalPending, count: students.length)
          : ListView.builder(itemCount: students.length, itemBuilder: (c,i){
        final s = students[i];
        return Card(margin: EdgeInsets.all(8), child: ListTile(
          leading: CircleAvatar(backgroundColor: s.remaining==0?Colors.green:Colors.orange, child: Text(s.name[0].toUpperCase(), style: TextStyle(color: Colors.white))),
          title: Text('${s.name} (${s.std})', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Mobile: ${s.phone}\nFee: ${s.paidFee}/${s.totalFee} | Baki: ${s.remaining}'),
          isThreeLine: true,
          trailing: IconButton(icon: Icon(Icons.currency_rupee), onPressed: ()=>payFeeDialog(i)),
        ));
      }),
      floatingActionButton: _index==1 ? FloatingActionButton(onPressed: addStudentDialog, child: Icon(Icons.add), backgroundColor: Colors.deepOrange) : null,
      bottomNavigationBar: BottomNavigationBar(currentIndex: _index, onTap: (v)=>setState(()=>_index=v), selectedItemColor: Colors.deepOrange, items: [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Vidyarthi'),
      ]),
    );
  }
}

class DashboardView extends StatelessWidget {
  final int totalCollection, totalPending, count;
  DashboardView({required this.totalCollection, required this.totalPending, required this.count});
  @override Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(16), child: Column(children: [
      Container(padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.deepOrange, borderRadius: BorderRadius.circular(16)), child: Column(children: [
        Text('Saikrupa Classes', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text('Karad', style: TextStyle(color: Colors.white70)),
        SizedBox(height: 10),
        Text('🙏 Vidya Vinayen Shobhate 🙏', style: TextStyle(color: Colors.white)),
      ])),
      SizedBox(height: 20),
      Row(children: [
        Expanded(child: _card('Vidyarthi', '$count', Icons.people, Colors.blue)),
        SizedBox(width: 10),
        Expanded(child: _card('Jama', '₹$totalCollection', Icons.check_circle, Colors.green)),
      ]),
      SizedBox(height: 10),
      _card('Baki Fee', '₹$totalPending', Icons.pending, Colors.red, full: true),
      SizedBox(height: 20),
      Text('Vidyarthi tab madhun navin vidyarthi add kara\nani fee jama kara', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
    ]));
  }
  Widget _card(String t, String v, IconData ic, Color c, {bool full=false}) {
    return Container(width: full?double.infinity:null, padding: EdgeInsets.all(16), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: c)), child: Column(children: [
      Icon(ic, color: c, size: 30), SizedBox(height: 8), Text(t, style: TextStyle(fontWeight: FontWeight.bold)), Text(v, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c)),
    ]));
  }
}
