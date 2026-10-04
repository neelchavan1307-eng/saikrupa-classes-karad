import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const MaterialApp(home: SaiKrupaPro(), debugShowCheckedModeBanner: false));

class Student {
  String name; int age; int std; int fee; List<int> paid;
  Student(this.name, this.age, this.std, this.fee, this.paid);
  Map toJson() => {"n":name,"a":age,"s":std,"f":fee,"p":paid};
  factory Student.fromJson(Map j) => Student(j["n"], j["a"], j["s"], j["f"], List<int>.from(j["p"]));
}

class SaiKrupaPro extends StatefulWidget {
  const SaiKrupaPro({super.key});
  @override State<SaiKrupaPro> createState() => _S();
}

class _S extends State<SaiKrupaPro> {
  List<Student> all = [];
  String search = ""; String filter = "सर्व";
  List<String> mL = ["J","F","M","A","M","J","J","A","S","O","N","D"];
  List<String> mN = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];

  // Profile Editable
  String className = "SAIKRUPA CLASSES";
  String profName = "Prof. Pradip Chavan";
  String address = "Karad";
  String phone = "9822001122";
  String? profileImagePath;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final sp = await SharedPreferences.getInstance();
    String? data = sp.getString("students");
    if(data!= null){
      List l = jsonDecode(data);
      all = l.map((e)=> Student.fromJson(e)).toList();
    } else {
      all = [
        Student("Vihan Tupe", 6, 6, 1000, [1,2,3,4,5,6,7,8]),
        Student("Krisha Kirme", 10, 10, 1200, [1,2,3,4,5,6,7]),
        Student("Anshuman Itape", 10, 10, 1000, [1,2,3,4,5,6,7]),
        Student("Aaradhya Yadav", 8, 8, 1000, [1,2,3,4]),
        Student("Swara Patil", 3, 3, 800, [1]),
      ];
    }
    className = sp.getString("cname")?? "SAIKRUPA CLASSES";
    profName = sp.getString("pname")?? "Prof. Pradip Chavan";
    address = sp.getString("addr")?? "Karad";
    phone = sp.getString("ph")?? "9822001122";
    profileImagePath = sp.getString("img");
    setState((){});
  }

  Future<void> saveData() async {
    final sp = await SharedPreferences.getInstance();
    sp.setString("students", jsonEncode(all.map((e)=>e.toJson()).toList()));
    sp.setString("cname", className);
    sp.setString("pname", profName);
    sp.setString("addr", address);
    sp.setString("ph", phone);
    if(profileImagePath!=null) sp.setString("img", profileImagePath!);
  }

  // ADD / EDIT STUDENT
  void showStudentDialog({Student? old, int? idx}){
    String n = old?.name?? ""; String a = old?.age.toString()?? ""; String s = old?.std.toString()?? ""; String f = old?.fee.toString()?? "";
    TextEditingController c1 = TextEditingController(text: n);
    TextEditingController c2 = TextEditingController(text: a);
    TextEditingController c3 = TextEditingController(text: s);
    TextEditingController c4 = TextEditingController(text: f);
    showDialog(context: context, builder: (_)=> AlertDialog(
      title: Text(old==null? "नवीन विद्यार्थी Add करा" : "विद्यार्थी Edit करा"),
      content: SingleChildScrollView(child: Column(children: [
        TextField(controller: c1, decoration: const InputDecoration(labelText: "नाव (Name)")),
        TextField(controller: c2, decoration: const InputDecoration(labelText: "वय (Age)"), keyboardType: TextInputType.number),
        TextField(controller: c3, decoration: const InputDecoration(labelText: "इयत्ता (Std)"), keyboardType: TextInputType.number),
        TextField(controller: c4, decoration: const InputDecoration(labelText: "Fee (Rs)"), keyboardType: TextInputType.number),
      ])),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(onPressed: (){
          if(c1.text.isEmpty) return;
          setState((){
            Student ns = Student(c1.text, int.tryParse(c2.text)??6, int.tryParse(c3.text)??6, int.tryParse(c4.text)??1000, old?.paid?? [1]);
            if(old==null) all.add(ns); else all[idx!] = ns;
          });
          saveData(); Navigator.pop(context);
        }, child: Text(old==null? "Add करा" : "Update करा"))
      ],
    ));
  }

  void deleteStudent(int idx){
    showDialog(context: context, builder: (_)=> AlertDialog(
      title: const Text("Delete करायचं?"),
      content: Text("${all[idx].name} ला Delete करायचं का?"),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text("नाही")),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: (){ setState(()=> all.removeAt(idx)); saveData(); Navigator.pop(context); }, child: const Text("होय Delete करा", style: TextStyle(color: Colors.white)))
      ],
    ));
  }

  // EDIT PROFILE
  void showProfileDialog(){
    TextEditingController c1 = TextEditingController(text: className);
    TextEditingController c2 = TextEditingController(text: profName);
    TextEditingController c3 = TextEditingController(text: address);
    TextEditingController c4 = TextEditingController(text: phone);
    showDialog(context: context, builder: (_)=> AlertDialog(
      title: const Text("Profile Edit करा"),
      content: SingleChildScrollView(child: Column(children: [
        TextField(controller: c1, decoration: const InputDecoration(labelText: "Class Name")),
        TextField(controller: c2, decoration: const InputDecoration(labelText: "Professor Name")),
        TextField(controller: c3, decoration: const InputDecoration(labelText: "Address (Karad)")),
        TextField(controller: c4, decoration: const InputDecoration(labelText: "Phone No")),
        const SizedBox(height: 10),
        ElevatedButton.icon(icon: const Icon(Icons.photo), label: const Text("Logo / Photo बदला"), onPressed: () async {
          final XFile? x = await ImagePicker().pickImage(source: ImageSource.gallery);
          if(x!=null){ setState(()=> profileImagePath = x.path); saveData(); }
        })
      ])),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(onPressed: (){ setState((){ className=c1.text; profName=c2.text; address=c3.text; phone=c4.text; }); saveData(); Navigator.pop(context); }, child: const Text("Save करा"))
      ],
    ));
  }

  // DIGITAL IMAGE RECEIPT WITH LOGO
  Future<void> genReceipt(Student s, int mi) async {
    String no = "SK-${Random().nextInt(9000)+1000}";
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const double W = 700, H = 850;

    // Background
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0,0,W,H), const Radius.circular(20)), Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0,0,W,H), const Radius.circular(20)), Paint()..color = Colors.orange..style=PaintingStyle.stroke..strokeWidth=8);

    // Load Logo
    try {
      ui.Image logoImg;
      if(profileImagePath!=null && File(profileImagePath!).existsSync()){
        final bytes = await File(profileImagePath!).readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final fi = await codec.getNextFrame();
        logoImg = fi.image;
      } else {
        final bd = await rootBundle.load('assets/logo.png');
        final codec = await ui.instantiateImageCodec(bd.buffer.asUint8List());
        final fi = await codec.getNextFrame();
        logoImg = fi.image;
      }
      canvas.drawImageRect(logoImg, Rect.fromLTWH(0,0,logoImg.width.toDouble(), logoImg.height.toDouble()), const Rect.fromLTWH(30,25,90,90), Paint());
    } catch(e){}

    void txt(String t, double x, double y, double sz, Color c, {bool b=false}){
      final tp = TextPainter(text: TextSpan(text: t, style: TextStyle(color: c, fontSize: sz, fontWeight: b?FontWeight.bold:FontWeight.normal)), textDirection: TextDirection.ltr); tp.layout(); tp.paint(canvas, Offset(x,y));
    }

    txt(className, 140, 30, 28, Colors.black, b:true);
    txt("$profName | $address | Ph: $phone", 140, 70, 16, Colors.red);
    canvas.drawLine(const Offset(30,125), const Offset(W-30,125), Paint()..color=Colors.orange..strokeWidth=2);
    txt("FEE RECEIPT", 250, 145, 28, const Color(0xFF2E7D32), b:true);
    txt("Receipt No: #$no", 30, 200, 18, Colors.black, b:true);
    txt("Date: 05/10/2026", 30, 230, 18, Colors.black);
    txt("Student Name: ${s.name}", 30, 280, 22, Colors.black, b:true);
    txt("Standard: ${s.std}th | Age: ${s.age}", 30, 315, 18, Colors.black);
    txt("Month: ${mN[mi]} 2025", 30, 360, 20, const Color(0xFF2E7D32), b:true);
    txt("Amount: Rs ${s.fee}/- PAID", 30, 395, 24, const Color(0xFF2E7D32), b:true);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(30,460,W-60,80), const Radius.circular(12)), Paint()..color=const Color(0xFFE8F5E9));
    txt("Fee Received, Thank you!", 200, 485, 22, const Color(0xFF2E7D32), b:true);
    txt("॥ श्री साईनाथाय नमः ॥", 230, 600, 20, Colors.orange, b:true);
    txt("Powered by Saikrupa Classes App", 200, 750, 14, Colors.grey);

    final pic = recorder.endRecording();
    final img = await pic.toImage(W.toInt(), H.toInt());
    final bd = await img.toByteData(format: ui.ImageByteFormat.png);
    final bytes = bd!.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/Receipt_${s.name}_$no.png");
    await file.writeAsBytes(bytes);

    if(!mounted) return;
    showDialog(context: context, builder: (_)=> Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.orange, width: 2)),
      child: Padding(padding: const EdgeInsets.all(12), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Image.memory(bytes, height: 400),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: ()=>Navigator.pop(context), child: const Text("Close"))),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.send), label: const Text("WhatsApp"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), onPressed: () async {
            await Share.shareXFiles([XFile(file.path)], text: "*$className* - Fee Receipt for ${s.name}");
          })),
        ])
      ])),
    ));
  }

  @override
  Widget build(BuildContext context) {
    List<Student> f = all.where((s)=> s.name.toLowerCase().contains(search.toLowerCase())).toList();
    if(filter=="बाकी") f = f.where((s)=> s.paid.length < 12).toList();
    if(filter=="संपलेला") f = f.where((s)=> s.paid.length == 12).toList();
    int totalPaid = all.fold(0, (a,b)=> a + b.fee * b.paid.length);
    int totalBal = all.fold(0, (a,b)=> a + b.fee * (12 - b.paid.length));

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      floatingActionButton: FloatingActionButton.extended(backgroundColor: Colors.green, icon: const Icon(Icons.person_add, color: Colors.white), label: const Text("नवीन विद्यार्थी", style: TextStyle(color: Colors.white)), onPressed: ()=> showStudentDialog()),
      appBar: AppBar(backgroundColor: Colors.white, title: Row(children: [
        profileImagePath!=null && File(profileImagePath!).existsSync()? CircleAvatar(backgroundImage: FileImage(File(profileImagePath!)), radius: 16) : Image.asset("assets/logo.png", width: 32, height: 32),
        const SizedBox(width: 8), Text(className, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black))
      ]), actions: [IconButton(icon: const Icon(Icons.edit, color: Colors.black), onPressed: showProfileDialog)]),
      body: SingleChildScrollView(child: Column(children: [
        // PROFILE HEADER - EDITABLE LIKE VIDEO
        Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.orange, Color(0xFFE040FB)])), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(children: [
          Row(children: [
            Stack(children: [
              profileImagePath!=null && File(profileImagePath!).existsSync()? CircleAvatar(radius: 32, backgroundImage: FileImage(File(profileImagePath!))) : Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle), child: CircleAvatar(radius: 30, backgroundColor: Colors.white, backgroundImage: const AssetImage("assets/logo.png"))),
              Positioned(bottom: 0, right: 0, child: InkWell(onTap: showProfileDialog, child: Container(decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle), padding: const EdgeInsets.all(4), child: const Icon(Icons.camera_alt, size: 14, color: Colors.white))))
            ]),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(className, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Row(children: [const Icon(Icons.school, size: 14, color: Colors.red), const SizedBox(width: 4), Text(profName, style: const TextStyle(fontSize: 12))]),
              const SizedBox(height: 6),
              Wrap(spacing: 6, children: [
                ActionChip(label: const Text("सेटिंग्स", style: TextStyle(fontSize: 10)), onPressed: showProfileDialog),
                ActionChip(label: const Text("माहिती बदला", style: TextStyle(fontSize: 10)), onPressed: showProfileDialog),
                ActionChip(backgroundColor: Colors.green, label: const Text("+ नवीन विद्यार्थी", style: TextStyle(fontSize: 10, color: Colors.white)), onPressed: ()=> showStudentDialog()),
              ])
            ]))
          ]),
          const SizedBox(height: 10),
          Row(children: [const Icon(Icons.location_on, size: 14, color: Colors.grey), Text(" $address", style: const TextStyle(fontSize: 11)), const Spacer(), const Icon(Icons.phone, size: 14, color: Colors.grey), Text(" $phone", style: const TextStyle(fontSize: 11))]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("एकूण विद्यार्थी", style: TextStyle(fontSize: 10)), Text("${all.length} विद्यार्थी", style: const TextStyle(fontWeight: FontWeight.bold))]))),
            const SizedBox(width: 8),
            Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("एकूण जमा", style: TextStyle(fontSize: 10)), Text("₹$totalPaid", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))]))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("बाकी", style: TextStyle(fontSize: 10)), Text("₹$totalBal", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))]))),
            const SizedBox(width: 8),
            Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(10)), child: const Text("WhatsApp ला पाठवा", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))),
          ])
        ]))),
        Padding(padding: const EdgeInsets.all(12), child: TextField(onChanged: (v)=> setState(()=> search=v), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: "विद्यार्थी शोधा...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [
          ChoiceChip(label: Text("सर्व (${all.length})"), selected: filter=="सर्व", onSelected: (_)=> setState(()=> filter="सर्व")),
          const SizedBox(width: 8),
          ChoiceChip(label: Text("बाकी (${all.where((s)=>s.paid.length<12).length})"), selected: filter=="बाकी", onSelected: (_)=> setState(()=> filter="बाकी")),
          const SizedBox(width: 8),
          ChoiceChip(label: const Text("संपलेला"), selected: filter=="संपलेला", onSelected: (_)=> setState(()=> filter="संपलेला")),
        ])),
        const SizedBox(height: 8),
       ...List.generate(f.length, (i){
          var s = f[i]; int paidAmt = s.fee * s.paid.length; int bal = s.fee * (12 - s.paid.length);
          return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(padding: const EdgeInsets.all(10), child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text("${s.name} | इ ${s.std} | Age ${s.age}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              Row(children: [
                IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.blue), onPressed: ()=> showStudentDialog(old: s, idx: all.indexOf(s))),
                IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: ()=> deleteStudent(all.indexOf(s))),
                Text("₹${s.fee}", style: const TextStyle(fontWeight: FontWeight.bold))
              ])
            ]),
            const SizedBox(height: 6),
            GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, childAspectRatio: 1.7, crossAxisSpacing: 4, mainAxisSpacing: 4), itemCount: 12, itemBuilder: (c,m){
              bool ok = s.paid.contains(m+1);
              return InkWell(onTap: (){ setState((){ if(ok) s.paid.remove(m+1); else s.paid.add(m+1); }); saveData(); }, child: Container(decoration: BoxDecoration(color: ok? Colors.green : const Color(0xFFFFCDD2), borderRadius: BorderRadius.circular(6)), child: Center(child: Text(mL[m], style: TextStyle(color: ok? Colors.white: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)))));
            }),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Paid ₹$paidAmt", style: const TextStyle(fontSize: 10)), Text("Bal ₹$bal", style: const TextStyle(fontSize: 10, color: Colors.red)),
              ElevatedButton(onPressed: ()=> genReceipt(s, DateTime.now().month-1), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, minimumSize: const Size(60,30)), child: const Text("पावती", style: TextStyle(fontSize: 10))),
              ElevatedButton(onPressed: ()=> genReceipt(s, DateTime.now().month-1), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: const Size(80,30)), child: const Text("Image WA", style: TextStyle(fontSize: 10))),
            ])
          ])));
        }),
        const SizedBox(height: 80)
      ])),
    );
  }
}
