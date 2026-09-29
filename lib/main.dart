import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}

class Student {
  String name; String phone; int fee; DateTime joinDate; List<bool> months;
  Student({required this.name, required this.phone, required this.fee, required this.joinDate, required this.months});
  int get paid => months.where((e) => e).length * fee;
  int get bal => (12 * fee) - paid;
  Map<String, dynamic> toJson() => {'name': name, 'phone': phone, 'fee': fee, 'joinDate': joinDate.toIso8601String(), 'months': months};
  factory Student.fromJson(Map<String, dynamic> j) => Student(name: j['name'], phone: j['phone'], fee: j['fee'], joinDate: DateTime.parse(j['joinDate']), months: List<bool>.from(j['months']));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Student> students = [];
  String search = "";
  String cName = "SAIKRUPA CLASSES";
  String cAddr = "Malakapur, Karad";
  String cPhone = "90220022XX";
  String? cImg;
  List<String> mShort = ["J","F","M","A","M","J","J","A","S","O","N","D"];
  List<String> mFull = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];

  @override
  void initState() { super.initState(); loadData(); }

  Future<void> loadData() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      cName = p.getString('cName')?? "SAIKRUPA CLASSES";
      cAddr = p.getString('cAddr')?? "Malakapur, Karad";
      cPhone = p.getString('cPhone')?? "90220022XX";
      cImg = p.getString('cImg');
    });
    String? d = p.getString('allStudents');
    if (d!= null) {
      List list = jsonDecode(d);
      setState(() { students = list.map((e) => Student.fromJson(e)).toList(); });
    }
  }

  Future<void> saveData() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('cName', cName);
    await p.setString('cAddr', cAddr);
    await p.setString('cPhone', cPhone);
    if (cImg!= null) await p.setString('cImg', cImg!);
    await p.setString('allStudents', jsonEncode(students.map((e) => e.toJson()).toList()));
  }

  Future<void> pickImg() async {
    final picker = ImagePicker();
    final XFile? x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
    if (x!= null) {
      final b = await x.readAsBytes();
      setState(() { cImg = base64Encode(b); });
      saveData();
    }
  }

  void editProfileDialog() {
    String n = cName; String a = cAddr; String ph = cPhone;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Profile Edit'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        InkWell(onTap: pickImg, child: CircleAvatar(radius: 35, backgroundImage: cImg!= null? MemoryImage(base64Decode(cImg!)) : null, child: cImg == null? const Icon(Icons.camera_alt) : null)),
        TextField(controller: TextEditingController(text: n), decoration: const InputDecoration(labelText: 'Name'), onChanged: (v){ n = v; }),
        TextField(controller: TextEditingController(text: a), decoration: const InputDecoration(labelText: 'Address'), onChanged: (v){ a = v; }),
        TextField(controller: TextEditingController(text: ph), decoration: const InputDecoration(labelText: 'Phone'), onChanged: (v){ ph = v; }),
      ]),
      actions: [
        TextButton(onPressed: (){ Navigator.pop(ctx); }, child: const Text('Cancel')),
        ElevatedButton(onPressed: (){ setState((){ cName = n; cAddr = a; cPhone = ph; }); saveData(); Navigator.pop(ctx); }, child: const Text('Save')),
      ],
    ));
  }

  void addStudentDialog() {
    String name = ""; String phone = ""; int fee = 500;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Add Student'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(decoration: const InputDecoration(labelText: 'Nav'), onChanged: (v){ name = v; }),
        TextField(decoration: const InputDecoration(labelText: 'Contact'), onChanged: (v){ phone = v; }),
        TextField(decoration: const InputDecoration(labelText: 'Fee'), controller: TextEditingController(text: '500'), keyboardType: TextInputType.number, onChanged: (v){ fee = int.tryParse(v)?? 500; }),
      ]),
      actions: [
        TextButton(onPressed: (){ Navigator.pop(ctx); }, child: const Text('Cancel')),
        ElevatedButton(onPressed: (){ if(name.isNotEmpty){ setState((){ students.add(Student(name: name, phone: phone, fee: fee, joinDate: DateTime.now(), months: List.filled(12, false))); }); saveData(); Navigator.pop(ctx); } }, child: const Text('Add')),
      ],
    ));
  }

  Future<void> sendReceipt(Student s, int idx) async {
    String msg = "*$cName* Fee Receipt\nStudent: ${s.name}\nMonth: ${mFull[idx]}\nFee: ${s.fee}\nPaid: ${s.paid} Bal: ${s.bal}";
    final uri = Uri.parse("https://wa.me/91${s.phone}?text=${Uri.encodeComponent(msg)}");
    if(await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> sendRemind(Student s) async {
    String msg = "Namaskar ${s.name} Palak, ${DateFormat('MMMM').format(DateTime.now())} fee Rs.${s.fee} baki aahe. Bal Rs.${s.bal} - $cName";
    final uri = Uri.parse("https://wa.me/91${s.phone}?text=${Uri.encodeComponent(msg)}");
    if(await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    int tPaid = students.fold(0, (a,b) => a + b.paid);
    int tBal = students.fold(0, (a,b) => a + b.bal);
    var filtered = students.where((e) => e.name.toLowerCase().contains(search.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: Text(cName), backgroundColor: Colors.orange, foregroundColor: Colors.white, actions: [IconButton(onPressed: editProfileDialog, icon: const Icon(Icons.edit))]),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(onTap: editProfileDialog, child: CircleAvatar(radius: 25, backgroundImage: cImg!= null? MemoryImage(base64Decode(cImg!)) : null, backgroundColor: Colors.orange.shade100, child: cImg == null? Text(cName[0]) : null)),
                    const SizedBox(width: 10),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(cName, style: const TextStyle(fontWeight: FontWeight.bold)), Text(cAddr, style: const TextStyle(fontSize: 11)), Text(cPhone, style: const TextStyle(fontSize: 10))]),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(6)), child: Column(children: [Text("${students.length}"), const Text("Students", style: TextStyle(fontSize: 9))]))),
                    const SizedBox(width: 5),
                    Expanded(child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(6)), child: Column(children: [Text("Rs.$tPaid"), const Text("Jama", style: TextStyle(fontSize: 9))]))),
                    const SizedBox(width: 5),
                    Expanded(child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(6)), child: Column(children: [Text("Rs.$tBal"), const Text("Baki", style: TextStyle(fontSize: 9))]))),
                  ],
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(8), child: TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), onChanged: (v){ setState((){ search = v; }); })),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 1000,
                child: ListView.builder(
                  itemCount: filtered.length + 1,
                  itemBuilder: (ctx, i){
                    if(i==0){
                      return Container(color: const Color(0xFF1E1E2F), padding: const EdgeInsets.all(8), child: Row(children: [
                        const SizedBox(width: 100, child: Text('Nav', style: TextStyle(color: Colors.white, fontSize: 12))),
                        const SizedBox(width: 80, child: Text('Contact', style: TextStyle(color: Colors.white, fontSize: 11))),
                        const SizedBox(width: 50, child: Text('Fee', style: TextStyle(color: Colors.white, fontSize: 11))),
                        const SizedBox(width: 60, child: Text('Join', style: TextStyle(color: Colors.white, fontSize: 11))),
                        Row(children: mShort.map((e) => Container(width: 32, margin: const EdgeInsets.symmetric(horizontal: 1), child: Center(child: Text(e, style: const TextStyle(color: Colors.white70, fontSize: 11))))).toList()),
                        const SizedBox(width: 90, child: Text('Action', style: TextStyle(color: Colors.white, fontSize: 11))),
                      ]));
                    }
                    Student s = filtered[i-1];
                    int realIdx = students.indexOf(s);
                    return Container(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 1),
                      padding: const EdgeInsets.all(6),
                      child: Row(
                        children: [
                          SizedBox(width: 100, child: Text(s.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                          SizedBox(width: 80, child: Text(s.phone, style: const TextStyle(fontSize: 10))),
                          SizedBox(width: 50, child: Text("Rs.${s.fee}", style: const TextStyle(fontSize: 10))),
                          SizedBox(width: 60, child: Text(DateFormat('dd-MM-yy').format(s.joinDate), style: const TextStyle(fontSize: 9))),
                          Row(children: List.generate(12, (mi){
                            bool ok = s.months[mi];
                            return InkWell(onTap: (){ setState((){ students[realIdx].months[mi] =!students[realIdx].months[mi]; }); saveData(); }, child: Container(width: 32, height: 24, margin: const EdgeInsets.symmetric(horizontal: 1), decoration: BoxDecoration(color: ok? Colors.green : Colors.red.shade300, borderRadius: BorderRadius.circular(4)), child: Icon(ok? Icons.check : Icons.close, size: 12, color: Colors.white)));
                          })),
                          Row(children: [
                            IconButton(icon: const Icon(Icons.receipt, size: 16, color: Colors.blue), onPressed: (){ int last = s.months.lastIndexWhere((e)=>e); if(last!= -1) sendReceipt(s, last); }),
                            InkWell(onTap: (){ sendRemind(s); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)), child: const Text('Remind', style: TextStyle(fontSize: 8, color: Colors.white)))),
                          ]),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: addStudentDialog, label: const Text('Add Student'), icon: const Icon(Icons.add), backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
    );
  }
}
