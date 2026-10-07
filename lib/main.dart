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
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(home: SaiKrupaPro(), debugShowCheckedModeBanner: false));

class Student {
  String name; int age; int std; int fee; List<int> paid; String? photo;
  String parentNumber;
  Student(this.name, this.age, this.std, this.fee, this.paid, {this.photo, this.parentNumber = ""});
  Map toJson() => {"n":name,"a":age,"s":std,"f":fee,"p":paid,"ph":photo, "pn": parentNumber};
  factory Student.fromJson(Map j) => Student(j["n"], j["a"], j["s"], j["f"], List<int>.from(j["p"]), photo: j["ph"], parentNumber: j["pn"]?.toString()??"");
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
    else {
      all = [
        Student("स्वरांश", 6, 6, 500, [], parentNumber: ""),
        Student("विहान तुपे", 6, 6, 600, [], parentNumber: ""),
        Student("क्रीशा कीरमे", 6, 6, 500, [], parentNumber: ""),
        Student("अंशुमन इतोपे", 6, 6, 600, [], parentNumber: ""),
        Student("आराध्या यादव", 6, 6, 700, [], parentNumber: ""),
        Student("सम्यक शिर्के", 6, 6, 500, [], parentNumber: ""),
        Student("श्रेया गादेकर", 6, 6, 500, [], parentNumber: ""),
        Student("स्वरा पाटील", 6, 6, 350, [], parentNumber: ""),
        Student("स्वरूप पाटील", 6, 6, 350, [], parentNumber: ""),
        Student("तेजल पाटील", 6, 6, 400, [], parentNumber: ""),
        Student("पुर्वी पाटील", 6, 6, 200, [], parentNumber: ""),
        Student("स्वसंस्कृती", 6, 6, 850, [], parentNumber: ""),
      ];
      saveData();
    }
    className = sp.getString("cname")?? className; profName = sp.getString("pname")?? profName;
    address = sp.getString("addr")?? address; phone = sp.getString("ph")?? phone; profileImagePath = sp.getString("img"); setState((){});
  }
  Future<void> saveData() async {
    final sp = await SharedPreferences.getInstance();
    sp.setString("students", jsonEncode(all.map((e)=>e.toJson()).toList()));
    sp.setString("cname", className); sp.setString("pname", profName);
    sp.setString("addr", address); sp.setString("ph", phone);
    if(profileImagePath!=null) sp.setString("img", profileImagePath!);
  }  Widget stuAvatar(Student s, double r){
    if(s.photo!=null && File(s.photo!).existsSync()){
      return CircleAvatar(radius: r, backgroundImage: FileImage(File(s.photo!)));
    } else {
      return CircleAvatar(radius: r, backgroundColor: Colors.orange[100], child: Text(s.name.isEmpty? "?" : s.name[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[800])));
    }
  }

  void showStudentDialog({Student? old, int? idx}){
    String tempPhoto = old?.photo?? "";
    TextEditingController c1 = TextEditingController(text: old?.name?? "");
    TextEditingController c2 = TextEditingController(text: old?.age.toString()?? "");
    TextEditingController c3 = TextEditingController(text: old?.std.toString()?? "");
    TextEditingController c4 = TextEditingController(text: old?.fee.toString()?? "");
    TextEditingController c5 = TextEditingController(text: old?.parentNumber?? "");
    showDialog(context: context, builder: (ctx){
      return StatefulBuilder(builder: (ctx2,setD){
        return AlertDialog(
          title: Text(old==null? "नवीन विद्यार्थी" : "Edit करा"),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(onTap: () async { final XFile? x = await ImagePicker().pickImage(source: ImageSource.gallery); if(x!=null){ setD(()=> tempPhoto = x.path); } },
              child: tempPhoto.isNotEmpty && File(tempPhoto).existsSync()? CircleAvatar(radius: 40, backgroundImage: FileImage(File(tempPhoto))) : CircleAvatar(radius: 40, backgroundColor: Colors.orange[100], child: Icon(Icons.person, size: 30))),
            const SizedBox(height: 8),
            TextField(controller: c1, decoration: const InputDecoration(labelText: "नाव *")),
            TextField(controller: c2, decoration: const InputDecoration(labelText: "वय"), keyboardType: TextInputType.number),
            TextField(controller: c3, decoration: const InputDecoration(labelText: "इयत्ता"), keyboardType: TextInputType.number),
            TextField(controller: c4, decoration: const InputDecoration(labelText: "Fee *"), keyboardType: TextInputType.number),
            TextField(controller: c5, decoration: const InputDecoration(labelText: "पालक WhatsApp नंबर (नसेल तर रिकामा)", hintText: "9822xxxxxx"), keyboardType: TextInputType.phone),
          ])),
          actions: [
            TextButton(onPressed: ()=> Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(onPressed: (){
              if(c1.text.isEmpty) return;
              setState((){
                Student ns = Student(c1.text, int.tryParse(c2.text)??6, int.tryParse(c3.text)??6, int.tryParse(c4.text)??1000, old?.paid?? [], photo: tempPhoto.isEmpty? null : tempPhoto, parentNumber: c5.text.trim());
                if(old==null) all.add(ns); else all[idx!] = ns;
              });
              saveData(); Navigator.pop(context);
            }, child: Text(old==null? "Add" : "Update"))
          ],
        );
      });
    });
  }

  Future<void> genReceipt(Student s, int mi, {bool autoWA = false}) async {
    String no = "SK-${Random().nextInt(9000)+1000}";
    final recorder = ui.PictureRecorder(); final canvas = Canvas(recorder);
    const double W = 700, H = 900;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0,0,W,H), const Radius.circular(20)), Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0,0,W,H), const Radius.circular(20)), Paint()..color = Colors.orange..style=PaintingStyle.stroke..strokeWidth=8);
    void txt(String t, double x, double y, double sz, Color c, {bool b=false}){
      final tp = TextPainter(text: TextSpan(text: t, style: TextStyle(color: c, fontSize: sz, fontWeight: b?FontWeight.bold:FontWeight.normal)), textDirection: TextDirection.ltr);
      tp.layout(); tp.paint(canvas, Offset(x,y));
    }
    txt(className, 30, 30, 28, Colors.black, b:true);
    txt("$profName | $address", 30, 70, 16, Colors.red);
    canvas.drawLine(const Offset(30,125), const Offset(W-30,125), Paint()..color=Colors.orange..strokeWidth=2);
    txt("FEE RECEIPT", 250, 145, 28, const Color(0xFF2E7D32), b:true);
    txt("Receipt No: #$no", 30, 200, 18, Colors.black, b:true);
    txt("Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}", 30, 230, 18, Colors.black);
    txt("Student: ${s.name}", 30, 280, 22, Colors.black, b:true);
    txt("Std: ${s.std}th | Fee: Rs ${s.fee}", 30, 315, 18, Colors.black);
    txt("Month: ${mN[mi]} 2025", 30, 360, 20, const Color(0xFF2E7D32), b:true);
    txt("Amount: Rs ${s.fee}/- PAID", 30, 395, 24, const Color(0xFF2E7D32), b:true);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(30,460,W-60,80), const Radius.circular(12)), Paint()..color=const Color(0xFFE8F5E9));
    txt("Fee Received, Thank you!", 200, 485, 22, const Color(0xFF2E7D32), b:true);
    final pic = recorder.endRecording(); final img = await pic.toImage(W.toInt(), H.toInt()); final bd = await img.toByteData(format: ui.ImageByteFormat.png); final bytes = bd!.buffer.asUint8List();
    final dir = await getTemporaryDirectory(); final file = File("${dir.path}/Receipt_${s.name}_$no.png"); await file.writeAsBytes(bytes);
    if(!mounted) return;
    if(autoWA && s.parentNumber.isNotEmpty){
      String text = "नमस्कार, ${s.name} ची ${mN[mi]} महिन्याची फी Rs ${s.fee} PAID झाली. - $className";
      await Share.shareXFiles([XFile(file.path)], text: text);
      String url = "https://wa.me/91${s.parentNumber}?text=${Uri.encodeComponent(text)}";
      if(await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return;
    }
    showDialog(context: context, builder: (_)=> Dialog(child: Padding(padding: const EdgeInsets.all(12), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Image.memory(bytes, height: 400), const SizedBox(height: 12),
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: ()=>Navigator.pop(context), child: const Text("Close"))),
        const SizedBox(width: 8),
        Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.send), label: const Text("WhatsApp"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), onPressed: () async {
          String text = "$className - Receipt for ${s.name}";
          if(s.parentNumber.isNotEmpty){
            String url = "https://wa.me/91${s.parentNumber}?text=${Uri.encodeComponent(text)}";
            if(await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          }
          await Share.shareXFiles([XFile(file.path)], text: text);
        }))
      ])
    ]))));
  }

  @override Widget build(BuildContext context) {
    List<Student> f = all.where((s)=> s.name.toLowerCase().contains(search.toLowerCase())).toList();
    int totalPaid = all.fold(0, (a,b)=> a + b.fee * b.paid.length);
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      floatingActionButton: FloatingActionButton.extended(backgroundColor: Colors.green, icon: const Icon(Icons.person_add, color: Colors.white), label: const Text("नवीन विद्यार्थी", style: TextStyle(color: Colors.white)), onPressed: ()=> showStudentDialog()),
      appBar: AppBar(backgroundColor: Colors.white, title: Text(className, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black))),
      body: SingleChildScrollView(child: Column(children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.orange, Color(0xFFE040FB)])), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(className, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), Text(profName, style: const TextStyle(fontSize: 12)), const SizedBox(height: 8), Text("एकूण विद्यार्थी: ${all.length} | जमा: Rs $totalPaid", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))]))]))),
        Padding(padding: const EdgeInsets.all(12), child: TextField(onChanged: (v)=> setState(()=> search=v), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: "शोधा...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white))),
       ...List.generate(f.length, (i){
          var s = f[i];
          return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), child: Padding(padding: const EdgeInsets.all(10), child: Column(children: [
            Row(children: [stuAvatar(s, 20), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("${s.name} - Rs ${s.fee}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text(s.parentNumber.isEmpty? "नंबर नाही - Long Press करून Add करा": "पालक: ${s.parentNumber}", style: TextStyle(fontSize: 10, color: s.parentNumber.isEmpty? Colors.red: Colors.green))]))]),
            const SizedBox(height: 6),
            GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, childAspectRatio: 1.7, crossAxisSpacing: 4, mainAxisSpacing: 4), itemCount: 12, itemBuilder: (c,m){
              bool ok = s.paid.contains(m+1);
              return InkWell(onTap: (){ setState((){ if(ok) s.paid.remove(m+1); else s.paid.add(m+1); }); saveData(); if(!ok) genReceipt(s, m, autoWA: true); }, child: Container(decoration: BoxDecoration(color: ok? Colors.green : const Color(0xFFFFCDD2), borderRadius: BorderRadius.circular(6)), child: Center(child: Text(mL[m], style: TextStyle(color: ok? Colors.white: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)))));
            }),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Paid: ${s.paid.length} महिने", style: const TextStyle(fontSize: 10)), ElevatedButton(onPressed: ()=> genReceipt(s, DateTime.now().month-1), child: const Text("पावती", style: TextStyle(fontSize: 10)))]),
          ])));
        }),
        const SizedBox(height: 80)
      ])),
    );
  }
}
