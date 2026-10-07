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
  String name; int age; int std; int fee; List<int> paid; String? photo; String parent;
  Student(this.name, this.age, this.std, this.fee, this.paid, {this.photo, this.parent = ""});
  Map toJson() => {"n":name,"a":age,"s":std,"f":fee,"p":paid,"ph":photo,"pn":parent};
  factory Student.fromJson(Map j) => Student(j["n"], j["a"], j["s"], j["f"], List<int>.from(j["p"]), photo: j["ph"], parent: j["pn"]??"");
}

class SaiKrupaPro extends StatefulWidget { const SaiKrupaPro({super.key}); @override State<SaiKrupaPro> createState() => _S(); }

class _S extends State<SaiKrupaPro> {
  List<Student> all = [];
  String search = "";
  List<String> mL = ["J","F","M","A","M","J","J","A","S","O","N","D"];
  List<String> mN = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
  String className = "SAIKRUPA CLASSES"; String profName = "Prof. Pradip Chavan";
  String address = "Karad"; String phone = ""; String? profileImagePath;

  @override void initState(){ super.initState(); loadData(); }

  Future<void> loadData() async {
    final sp = await SharedPreferences.getInstance();
    String? data = sp.getString("students");
    if(data!= null){ List l = jsonDecode(data); all = l.map((e)=> Student.fromJson(e)).toList(); }
    else {
      // तुझ्या फोटो वरची 12 नावं - Ready
      all = [
        Student("स्वरांश", 6, 6, 500, [], parent: ""),
        Student("विहान तुपे", 6, 6, 600, [], parent: ""),
        Student("क्रीशा कीरमे", 6, 6, 500, [], parent: ""),
        Student("अंशुमन इतोपे", 6, 6, 600, [], parent: ""),
        Student("आराध्या यादव", 6, 6, 700, [], parent: ""),
        Student("सम्यक शिर्के", 6, 6, 500, [], parent: ""),
        Student("श्रेया गादेकर", 6, 6, 500, [], parent: ""),
        Student("स्वरा पाटील", 6, 6, 350, [], parent: ""),
        Student("स्वरूप पाटील", 6, 6, 350, [], parent: ""),
        Student("तेजल पाटील", 6, 6, 400, [], parent: ""),
        Student("पुर्वी पाटील", 6, 6, 200, [], parent: ""),
        Student("स्वसंस्कृती", 6, 6, 850, [], parent: ""),
      ];
      saveData();
    }
    setState((){});
  }
  Future<void> saveData() async {
    final sp = await SharedPreferences.getInstance();
    sp.setString("students", jsonEncode(all.map((e)=>e.toJson()).toList()));
  }

  Widget stuAvatar(Student s, double r){
    if(s.photo!=null && File(s.photo!).existsSync()) return CircleAvatar(radius: r, backgroundImage: FileImage(File(s.photo!)));
    return CircleAvatar(radius: r, backgroundColor: Colors.orange[100], child: Text(s.name.isEmpty?"?":s.name[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[800])));
  }

  void showStudentDialog({Student? old, int? idx}){
    String tempPhoto = old?.photo?? "";
    TextEditingController c1 = TextEditingController(text: old?.name?? "");
    TextEditingController c4 = TextEditingController(text: old?.fee.toString()?? "");
    TextEditingController c5 = TextEditingController(text: old?.parent?? "");
    showDialog(context: context, builder: (ctx){
      return StatefulBuilder(builder: (ctx2,setD){
        return AlertDialog(
          title: Text(old==null? "नवीन विद्यार्थी" : "Edit करा"),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(onTap: () async { final XFile? x = await ImagePicker().pickImage(source: ImageSource.gallery); if(x!=null){ setD(()=> tempPhoto = x.path); } },
              child: Stack(children: [
                tempPhoto.isNotEmpty && File(tempPhoto).existsSync()? CircleAvatar(radius: 40, backgroundImage: FileImage(File(tempPhoto))) : CircleAvatar(radius: 40, backgroundColor: Colors.orange[100], child: Text(c1.text.isEmpty?"?":c1.text[0].toUpperCase(), style: const TextStyle(fontSize: 30))),
                Positioned(bottom: 0, right: 0, child: Container(decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle), padding: const EdgeInsets.all(6), child: const Icon(Icons.camera_alt, size: 16, color: Colors.white)))
              ])),
            const SizedBox(height: 10),
            TextField(controller: c1, decoration: const InputDecoration(labelText: "नाव")),
            TextField(controller: c4, decoration: const InputDecoration(labelText: "Fee"), keyboardType: TextInputType.number),
            TextField(controller: c5, decoration: const InputDecoration(labelText: "पालक नंबर - Long Press Add"), keyboardType: TextInputType.phone),
          ])),
          actions: [
            TextButton(onPressed: ()=> Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(onPressed: (){
              if(c1.text.isEmpty) return;
              setState((){
                Student ns = Student(c1.text, 6, 6, int.tryParse(c4.text)??500, old?.paid??[], photo: tempPhoto.isEmpty? null : tempPhoto, parent: c5.text.trim());
                if(old==null) all.add(ns); else all[idx!] = ns;
              });
              saveData(); Navigator.pop(context);
            }, child: Text(old==null? "Add" : "Update"))
          ],
        );
      });
    });
  }

  Future<void> genReceipt(Student s, int mi) async {
    String no = "SK-${Random().nextInt(9000)+1000}";
    final recorder = ui.PictureRecorder(); final canvas = Canvas(recorder);
    const double W = 700, H = 900;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0,0,W,H), const Radius.circular(20)), Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0,0,W,H), const Radius.circular(20)), Paint()..color = Colors.orange..style=PaintingStyle.stroke..strokeWidth=6);
    try {
      final bd = await rootBundle.load('assets/logo.png');
      final codec = await ui.instantiateImageCodec(bd.buffer.asUint8List());
      final fi = await codec.getNextFrame();
      canvas.drawImageRect(fi.image, Rect.fromLTWH(0,0,fi.image.width.toDouble(), fi.image.height.toDouble()), const Rect.fromLTWH(30,25,80,80), Paint());
    } catch(e){}
    void txt(String t, double x, double y, double sz, Color c, {bool b=false}){
      final tp = TextPainter(text: TextSpan(text: t, style: TextStyle(color: c, fontSize: sz, fontWeight: b?FontWeight.bold:FontWeight.normal)), textDirection: TextDirection.ltr);
      tp.layout(); tp.paint(canvas, Offset(x,y));
    }
    txt(className, 130, 30, 26, Colors.black, b:true);
    txt("Prof. Pradip Chavan", 130, 65, 14, Colors.black54);
    canvas.drawLine(const Offset(30,115), const Offset(W-30,115), Paint()..color=Colors.orange..strokeWidth=2);
    txt("FEE RECEIPT", 250, 135, 26, const Color(0xFF2E7D32), b:true);
    txt("Receipt No: #$no", 30, 190, 18, Colors.black, b:true);
    txt("Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}", 30, 220, 18, Colors.black);
    txt("Student: ${s.name}", 30, 270, 22, Colors.black, b:true);
    txt("Std: ${s.std}th | Fee Rs ${s.fee}", 30, 305, 18, Colors.black);
    txt("Month: ${mN[mi]} 2025", 30, 350, 20, const Color(0xFF2E7D32), b:true);
    txt("Amount: Rs ${s.fee}/- PAID", 30, 385, 24, const Color(0xFF2E7D32), b:true);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(30,450,W-60,70), const Radius.circular(12)), Paint()..color=const Color(0xFFE8F5E9));
    txt("Fee Received, Thank you!", 210, 472, 20, const Color(0xFF2E7D32), b:true);
    txt("Shri Swami Samarthay Namah", 220, 650, 18, Colors.orange, b:true);
    final pic = recorder.endRecording(); final img = await pic.toImage(W.toInt(), H.toInt()); final bd = await img.toByteData(format: ui.ImageByteFormat.png); final bytes = bd!.buffer.asUint8List();
    final dir = await getTemporaryDirectory(); final file = File("${dir.path}/Receipt_${s.name}_$no.png"); await file.writeAsBytes(bytes);
    if(!mounted) return;
    showDialog(context: context, builder: (_)=> Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.orange, width: 2)), child: Padding(padding: const EdgeInsets.all(12), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Image.memory(bytes, height: 380), const SizedBox(height: 10),
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: ()=>Navigator.pop(context), child: const Text("Close"))),
        const SizedBox(width: 8),
        Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.send), label: const Text("WhatsApp"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), onPressed: () async { await Share.shareXFiles([XFile(file.path)], text: "$className - Receipt for ${s.name}"); }))
      ])
    ]))));
  }

  @override Widget build(BuildContext context) {
    List<Student> f = all.where((s)=> s.name.toLowerCase().contains(search.toLowerCase())).toList();
    int totalFee = all.fold(0, (a,b)=> a + b.fee);
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      floatingActionButton: FloatingActionButton.extended(backgroundColor: Colors.green, icon: const Icon(Icons.person_add, color: Colors.white), label: const Text("नवीन विद्यार्थी", style: TextStyle(color: Colors.white)), onPressed: ()=> showStudentDialog()),
      appBar: AppBar(backgroundColor: Colors.white, title: const Text("SAIKRUPA CLASSES", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black))),
      body: Column(children: [
        Container(width: double.infinity, margin: const EdgeInsets.all(10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200), gradient: LinearGradient(colors: [Colors.white, Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Image.asset("assets/logo.png", width: 32, height: 32, errorBuilder: (c,e,s)=> const Icon(Icons.school)), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(className, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text("$profName", style: const TextStyle(fontSize: 11))])]),
          const SizedBox(height: 6),
          Text("एकूण विद्यार्थी: ${all.length} | एकूण फी: Rs $totalFee", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ])),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: TextField(onChanged: (v)=> setState(()=> search=v), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: "शोधा...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white))),
        const SizedBox(height: 8),
        Expanded(child: ListView.builder(itemCount: f.length, itemBuilder: (c,i){
          var s = f[i]; int idx = all.indexOf(s);
          return GestureDetector(
            onLongPress: (){
              showModalBottomSheet(context: context, builder: (_)=> Container(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [
                stuAvatar(s, 30), const SizedBox(height: 8), Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                ListTile(leading: const Icon(Icons.edit, color: Colors.blue), title: const Text("Edit करा - पालक नंबर Add करा"), onTap: (){ Navigator.pop(context); showStudentDialog(old: s, idx: idx); }),
                ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text("Delete करा"), onTap: (){ setState(()=> all.removeAt(idx)); saveData(); Navigator.pop(context); }),
              ])));
            },
            child: Card(margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(padding: const EdgeInsets.all(10), child: Column(children: [
              Row(children: [
                CircleAvatar(radius: 14, backgroundColor: Colors.orange[100], child: Text(s.name[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("${s.name} - Rs ${s.fee}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(s.parent.isEmpty? "नंबर नाही - Long Press Add": "पालक: ${s.parent}", style: TextStyle(fontSize: 9, color: s.parent.isEmpty? Colors.red: Colors.green)),
                ])),
              ]),
              const SizedBox(height: 8),
              GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, childAspectRatio: 1.6, crossAxisSpacing: 4, mainAxisSpacing: 4), itemCount: 12, itemBuilder: (c,m){
                bool ok = s.paid.contains(m+1);
                return InkWell(onTap: (){ setState((){ if(ok) s.paid.remove(m+1); else s.paid.add(m+1); }); saveData(); }, child: Container(decoration: BoxDecoration(color: ok? Colors.green : const Color(0xFFFFCDD2), borderRadius: BorderRadius.circular(6)), child: Center(child: Text(mL[m], style: TextStyle(color: ok? Colors.white: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)))));
              }),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Paid: ${s.paid.length} महिने", style: const TextStyle(fontSize: 10)),
                ElevatedButton(onPressed: ()=> genReceipt(s, DateTime.now().month-1), style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade100, foregroundColor: Colors.black, minimumSize: const Size(70,28)), child: const Text("पावती", style: TextStyle(fontSize: 11))),
              ])
            ]))),
          );
        })),
      ]),
    );
  }
}
