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
import 'package:file_picker/file_picker.dart';

void main() => runApp(const MaterialApp(home: SaiKrupaPro(), debugShowCheckedModeBanner: false));

class Student {
  String name; int age; int std; int fee; List<int> paid; String? photo;
  Student(this.name, this.age, this.std, this.fee, this.paid, {this.photo});
  Map toJson() => {"n":name,"a":age,"s":std,"f":fee,"p":paid,"ph":photo};
  factory Student.fromJson(Map j) => Student(j["n"], j["a"], j["s"], j["f"], List<int>.from(j["p"]), photo: j["ph"]);
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
  String className = "SAIKRUPA CLASSES"; String profName = "Prof. Pradip Chavan";
  String address = "Karad"; String phone = "9822001122"; String? profileImagePath;

  @override void initState(){ super.initState(); loadData(); }

  Future<void> loadData() async {
    final sp = await SharedPreferences.getInstance();
    String? data = sp.getString("students");
    if(data!= null){ List l = jsonDecode(data); all = l.map((e)=> Student.fromJson(e)).toList(); }
    else { all = [Student("Vihan Tupe", 6, 6, 1000, [1,2,3,4,5,6,7,8]), Student("Krisha Kirme", 10, 10, 1200, [1,2,3,4,5,6,7])]; }
    className = sp.getString("cname")?? className; profName = sp.getString("pname")?? profName;
    address = sp.getString("addr")?? address; phone = sp.getString("ph")?? phone; profileImagePath = sp.getString("img"); setState((){});
  }
  Future<void> saveData() async {
    final sp = await SharedPreferences.getInstance();
    sp.setString("students", jsonEncode(all.map((e)=>e.toJson()).toList()));
    sp.setString("cname", className); sp.setString("pname", profName);
    sp.setString("addr", address); sp.setString("ph", phone);
    if(profileImagePath!=null) sp.setString("img", profileImagePath!);
  }

  Future<void> backupExport() async {
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/Saikrupa_Backup.json");
    await file.writeAsString(jsonEncode(all.map((e)=>e.toJson()).toList()));
    await Share.shareXFiles([XFile(file.path)], text: "SAIKRUPA BACKUP - ${all.length} Students");
  }

  Future<void> backupImport() async {
    FilePickerResult? res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if(res!=null){
      try{
        String content = await File(res.files.single.path!).readAsString();
        List l = jsonDecode(content);
        setState(()=> all = l.map((e)=> Student.fromJson(e)).toList());
        saveData();
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${all.length} Restore झाले")));
      }catch(e){
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Backup File चुकीची आहे")));
      }
    }
  }

  void showStudentDialog({Student? old, int? idx}){
    String tempPhoto = old?.photo?? "";
    TextEditingController c1 = TextEditingController(text: old?.name?? "");
    TextEditingController c2 = TextEditingController(text: old?.age.toString()?? "");
    TextEditingController c3 = TextEditingController(text: old?.std.toString()?? "");
    TextEditingController c4 = TextEditingController(text: old?.fee.toString()?? "");
    showDialog(context: context, builder: (ctx){
      return StatefulBuilder(builder: (ctx2,setD){
        return AlertDialog(
          title: Text(old==null? "नवीन विद्यार्थी" : "Edit करा"),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(
              onTap: () async {
                final XFile? x = await ImagePicker().pickImage(source: ImageSource.gallery);
                if(x!=null){ setD(()=> tempPhoto = x.path); }
              },
              child: Stack(children: [
                tempPhoto.isNotEmpty && File(tempPhoto).existsSync()? CircleAvatar(radius: 40, backgroundImage: FileImage(File(tempPhoto))) : CircleAvatar(radius: 40, backgroundColor: Colors.orange[100], child: Text(c1.text.isEmpty? "?" : c1.text[0].toUpperCase(), style: const TextStyle(fontSize: 30))),
                Positioned(bottom: 0, right: 0, child: Container(decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle), padding: const EdgeInsets.all(6), child: const Icon(Icons.camera_alt, size: 16, color: Colors.white)))
              ])
            ),
            const SizedBox(height: 12),
            const Text("फोटो लावण्यासाठी वर Click करा", style: TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(controller: c1, decoration: const InputDecoration(labelText: "नाव")),
            TextField(controller: c2, decoration: const InputDecoration(labelText: "वय"), keyboardType: TextInputType.number),
            TextField(controller: c3, decoration: const InputDecoration(labelText: "इयत्ता"), keyboardType: TextInputType.number),
            TextField(controller: c4, decoration: const InputDecoration(labelText: "Fee"), keyboardType: TextInputType.number),
          ])),
          actions: [
            TextButton(onPressed: ()=> Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(onPressed: (){
              if(c1.text.isEmpty) return;
              setState((){
                Student ns = Student(c1.text, int.tryParse(c2.text)??6, int.tryParse(c3.text)??6, int.tryParse(c4.text)??1000, old?.paid?? [1], photo: tempPhoto.isEmpty? null : tempPhoto);
                if(old==null) all.add(ns); else all[idx!] = ns;
              });
              saveData(); Navigator.pop(context);
            }, child: Text(old==null? "Add" : "Update"))
          ],
        );
      });
    });
  }

  void deleteStudent(int idx){
    showDialog(context: context, builder: (_)=> AlertDialog(
      title: const Text("Delete?"),
      content: Text("${all[idx].name} Delete करायचे?"),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text("नाही")),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: (){ setState(()=> all.removeAt(idx)); saveData(); Navigator.pop(context); }, child: const Text("होय", style: TextStyle(color: Colors.white)))
      ]
    ));
  }

  void showProfileDialog(){
    TextEditingController c1 = TextEditingController(text: className); TextEditingController c2 = TextEditingController(text: profName);
    TextEditingController c3 = TextEditingController(text: address); TextEditingController c4 = TextEditingController(text: phone);
    showDialog(context: context, builder: (_)=> AlertDialog(title: const Text("Profile Edit"), content: SingleChildScrollView(child: Column(children: [
      TextField(controller: c1, decoration: const InputDecoration(labelText: "Class Name")),
      TextField(controller: c2, decoration: const InputDecoration(labelText: "Professor")),
      TextField(controller: c3, decoration: const InputDecoration(labelText: "Address")),
      TextField(controller: c4, decoration: const InputDecoration(labelText: "Phone")),
      const SizedBox(height: 10),
      ElevatedButton.icon(icon: const Icon(Icons.photo), label: const Text("Logo बदला"), onPressed: () async { final XFile? x = await ImagePicker().pickImage(source: ImageSource.gallery); if(x!=null){ setState(()=> profileImagePath = x.path); saveData(); } })
    ])), actions: [
      TextButton(onPressed: ()=> Navigator.pop(context), child: const Text("Cancel")),
      ElevatedButton(onPressed: (){ setState((){ className=c1.text; profName=c2.text; address=c3.text; phone=c4.text; }); saveData(); Navigator.pop(context); }, child: const Text("Save"))
    ]));
  }

  Future<void> genReceipt(Student s, int mi) async {
    String no = "SK-${Random().nextInt(9000)+1000}";
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const double W = 700, H = 900;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0,0,W,H), const Radius.circular(20)), Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0,0,W,H), const Radius.circular(20)), Paint()..color = Colors.orange..style=PaintingStyle.stroke..strokeWidth=8);
    ui.Image? studentImg;
    try {
      if(s.photo!=null && File(s.photo!).existsSync()){
        final bytes = await File(s.photo!).readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes, targetWidth: 200);
        final fi = await codec.getNextFrame();
        studentImg = fi.image;
      }
    } catch(e){}
    try {
      ui.Image logoImg;
      if(profileImagePath!=null && File(profileImagePath!).existsSync()){
        final bytes = await File(profileImagePath!).readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final fi = await codec.getNextFrame(); logoImg = fi.image;
      } else {
        final bd = await rootBundle.load('assets/logo.png');
        final codec = await ui.instantiateImageCodec(bd.buffer.asUint8List());
        final fi = await codec.getNextFrame(); logoImg = fi.image;
      }
      canvas.drawImageRect(logoImg, Rect.fromLTWH(0,0,logoImg.width.toDouble(), logoImg.height.toDouble()), const Rect.fromLTWH(30,25,90,90), Paint());
    } catch(e){}
    if(studentImg!=null){
      canvas.drawImageRect(studentImg, Rect.fromLTWH(0,0,studentImg.width.toDouble(), studentImg.height.toDouble()), const Rect.fromLTWH(560,200,110,110), Paint());
    }
    void txt(String t, double x, double y, double sz, Color c, {bool b=false}){
      final tp = TextPainter(text: TextSpan(text: t, style: TextStyle(color: c, fontSize: sz, fontWeight: b?FontWeight.bold:FontWeight.normal)), textDirection: TextDirection.ltr);
      tp.layout(); tp.paint(canvas, Offset(x,y));
    }
    txt(className, 140, 30, 28, Colors.black, b:true);
    txt("$profName | $address | Ph: $phone", 140, 70, 16, Colors.red);
    canvas.drawLine(const Offset(30,125), const Offset(W-30,125), Paint()..color=Colors.orange..strokeWidth=2);
    txt("FEE RECEIPT", 250, 145, 28, const Color(0xFF2E7D32), b:true);
    txt("Receipt No: #$no", 30, 200, 18, Colors.black, b:true);
    txt("Date: 05/10/2026", 30, 230, 18, Colors.black);
    txt("Student: ${s.name}", 30, 280, 22, Colors.black, b:true);
    txt("Std: ${s.std}th | Age: ${s.age}", 30, 315, 18, Colors.black);
    txt("Month: ${mN[mi]} 2025", 30, 360, 20, const Color(0xFF2E7D32), b:true);
    txt("Amount: Rs ${s.fee}/- PAID", 30, 395, 24, const Color(0xFF2E7D32), b:true);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(30,460,W-60,80), const Radius.circular(12)), Paint()..color=const Color(0xFFE8F5E9));
    txt("Fee Received, Thank you!", 200, 485, 22, const Color(0xFF2E7D32), b:true);
    txt("Shri Sainathay Namah", 230, 650, 20, Colors.orange, b:true);
    final pic = recorder.endRecording(); final img = await pic.toImage(W.toInt(), H.toInt()); final bd = await img.toByteData(format: ui.ImageByteFormat.png); final bytes = bd!.buffer.asUint8List();
    final dir = await getTemporaryDirectory(); final file = File("${dir.path}/Receipt_${s.name}_$no.png"); await file.writeAsBytes(bytes);
    if(!mounted) return;
    showDialog(context: context, builder: (_)=> Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.orange, width: 2)), child: Padding(padding: const EdgeInsets.all(12), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Image.memory(bytes, height: 400), const SizedBox(height: 12),
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: ()=>Navigator.pop(context), child: const Text("Close"))),
        const SizedBox(width: 8),
        Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.send), label: const Text("WhatsApp"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), onPressed: () async { await Share.shareXFiles([XFile(file.path)], text: "$className - Receipt for ${s.name}"); }))
      ])
    ]))));
  }

  Widget studentAvatar(Student s, double r){
    if(s.photo!=null && File(s.photo!).existsSync()){
      return CircleAvatar(radius: r, backgroundImage: FileImage(File(s.photo!)));
    } else {
      return CircleAvatar(radius: r, backgroundColor: Colors.orange[100], child: Text(s.name.isEmpty? "?" : s.name[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[800])));
    }
  }

  @override Widget build(BuildContext context) {
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
        const SizedBox(width: 8),
        Text(className, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black))
      ]), actions: [
        IconButton(icon: const Icon(Icons.backup, color: Colors.black), onPressed: backupExport),
        IconButton(icon: const Icon(Icons.restore, color: Colors.black), onPressed: backupImport),
        IconButton(icon: const Icon(Icons.edit, color: Colors.black), onPressed: showProfileDialog)
      ]),
      body: SingleChildScrollView(child: Column(children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.orange, Color(0xFFE040FB)])), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(children: [
          Row(children: [
            Stack(children: [
              profileImagePath!=null && File(profileImagePath!).existsSync()? CircleAvatar(radius: 32, backgroundImage: FileImage(File(profileImagePath!))) : Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle), child: const CircleAvatar(radius: 30, backgroundColor: Colors.white, backgroundImage: AssetImage("assets/logo.png"))),
              Positioned(bottom: 0, right: 0, child: InkWell(onTap: showProfileDialog, child: Container(decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle), padding: const EdgeInsets.all(4), child: const Icon(Icons.camera_alt, size: 14, color: Colors.white))))
            ]),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(className, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Row(children: [const Icon(Icons.school, size: 14, color: Colors.red), const SizedBox(width: 4), Text(profName, style: const TextStyle(fontSize: 12))]),
              const SizedBox(height: 6),
              Wrap(spacing: 6, children: [
                ActionChip(label: const Text("सेटिंग्स", style: TextStyle(fontSize: 10)), onPressed: showProfileDialog),
                ActionChip(label: const Text("बॅकअप", style: TextStyle(fontSize: 10)), onPressed: backupExport),
                ActionChip(backgroundColor: Colors.green, label: const Text("+ नवीन विद्यार्थी", style: TextStyle(fontSize: 10, color: Colors.white)), onPressed: ()=> showStudentDialog())
              ])
            ]))
          ]),
          const SizedBox(height: 10),
          Row(children: [const Icon(Icons.location_on, size: 14, color: Colors.grey), Text(" $address", style: const TextStyle(fontSize: 11)), const Spacer(), const Icon(Icons.phone, size: 14, color: Colors.grey), Text(" $phone", style: const TextStyle(fontSize: 11))]),
        ]))),
        Padding(padding: const EdgeInsets.all(12), child: TextField(onChanged: (v)=> setState(()=> search=v), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: "विद्यार्थी शोधा...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white))),
        const SizedBox(height: 8),
       ...List.generate(f.length, (i){
          var s = f[i]; int paidAmt = s.fee * s.paid.length; int bal = s.fee * (12 - s.paid.length);
          return GestureDetector(
            onLongPress: (){
              showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_)=> Container(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 12), studentAvatar(s, 30), const SizedBox(height: 8), Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 12),
                ListTile(leading: const Icon(Icons.edit, color: Colors.blue), title: const Text("Edit करा - फोटो / नाव बदला"), onTap: (){ Navigator.pop(context); showStudentDialog(old: s, idx: all.indexOf(s)); }),
                ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text("Delete करा"), onTap: (){ Navigator.pop(context); deleteStudent(all.indexOf(s)); }),
                ListTile(leading: const Icon(Icons.close), title: const Text("Cancel"), onTap: ()=> Navigator.pop(context)),
              ])));
            },
            child: Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(padding: const EdgeInsets.all(10), child: Column(children: [
              Row(children: [
                studentAvatar(s, 22),
                const SizedBox(width: 8),
                Expanded(child: Text("${s.name} | इ ${s.std} | Age ${s.age}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Text("Rs ${s.fee}", style: const TextStyle(fontWeight: FontWeight.bold))
              ]),
              const SizedBox(height: 6),
              GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, childAspectRatio: 1.7, crossAxisSpacing: 4, mainAxisSpacing: 4), itemCount: 12, itemBuilder: (c,m){ bool ok = s.paid.contains(m+1); return InkWell(onTap: (){ setState((){ if(ok) s.paid.remove(m+1); else s.paid.add(m+1); }); saveData(); }, child: Container(decoration: BoxDecoration(color: ok? Colors.green : const Color(0xFFFFCDD2), borderRadius: BorderRadius.circular(6)), child:
