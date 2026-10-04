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

void main() {
  runApp(const MaterialApp(home: SaiKrupaApp(), debugShowCheckedModeBanner: false));
}

class Student {
  String name; int age; int std; int fee; List<int> paid; String? photo;
  Student(this.name, this.age, this.std, this.fee, this.paid, {this.photo});
  Map toJson() => {"n": name, "a": age, "s": std, "f": fee, "p": paid, "ph": photo};
  factory Student.fromJson(Map j) => Student(j["n"], j["a"], j["s"], j["f"], List<int>.from(j["p"]), photo: j["ph"]);
}

class SaiKrupaApp extends StatefulWidget {
  const SaiKrupaApp({super.key});
  @override State<SaiKrupaApp> createState() => SaiKrupaState();
}

class SaiKrupaState extends State<SaiKrupaApp> {
  List<Student> all = [];
  String search = "";
  String filter = "All";
  List<String> mL = ["J","F","M","A","M","J","J","A","S","O","N","D"];
  List<String> mN = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
  String className = "SAIKRUPA CLASSES";
  String profName = "Prof. Pradip Chavan";
  String address = "Karad";
  String phone = "9822001122";
  String? logoPath;

  @override void initState() { super.initState(); load(); }

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    String? d = sp.getString("students");
    if (d!= null) {
      List l = jsonDecode(d);
      all = l.map((e) => Student.fromJson(e)).toList();
    } else {
      all = [Student("Vihan Tupe", 6, 6, 1000, [1,2,3,4]), Student("Krisha Kirme", 10, 10, 1200, [1,2,3])];
    }
    className = sp.getString("cname")?? className;
    profName = sp.getString("pname")?? profName;
    address = sp.getString("addr")?? address;
    phone = sp.getString("ph")?? phone;
    logoPath = sp.getString("logo");
    setState(() {});
  }

  Future<void> save() async {
    final sp = await SharedPreferences.getInstance();
    sp.setString("students", jsonEncode(all.map((e) => e.toJson()).toList()));
    sp.setString("cname", className);
    sp.setString("pname", profName);
    sp.setString("addr", address);
    sp.setString("ph", phone);
    if (logoPath!= null) sp.setString("logo", logoPath!);
  }

  Future<void> backupExport() async {
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/Saikrupa_Backup.json");
    await file.writeAsString(jsonEncode(all.map((e) => e.toJson()).toList()));
    await Share.shareXFiles([XFile(file.path)], text: "Backup ${all.length} Students");
  }

  Future<void> backupImport() async {
    FilePickerResult? r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (r!= null) {
      try {
        String c = await File(r.files.single.path!).readAsString();
        List l = jsonDecode(c);
        setState(() => all = l.map((e) => Student.fromJson(e)).toList());
        save();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${all.length} Restore done")));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Wrong file")));
      }
    }
  }

  Widget avatar(Student s, double rad) {
    if (s.photo!= null && File(s.photo!).existsSync()) {
      return CircleAvatar(radius: rad, backgroundImage: FileImage(File(s.photo!)));
    }
    return CircleAvatar(radius: rad, backgroundColor: Colors.orange[100], child: Text(s.name.isEmpty? "?" : s.name[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[800])));
  }

  void studentDialog({Student? old, int? idx}) {
    String tmpPhoto = old?.photo?? "";
    TextEditingController c1 = TextEditingController(text: old?.name?? "");
    TextEditingController c2 = TextEditingController(text: old?.age.toString()?? "");
    TextEditingController c3 = TextEditingController(text: old?.std.toString()?? "");
    TextEditingController c4 = TextEditingController(text: old?.fee.toString()?? "");
    showDialog(context: context, builder: (ctx) {
      return StatefulBuilder(builder: (c2b, setD) {
        return AlertDialog(
          title: Text(old == null? "Add Student" : "Edit Student"),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(onTap: () async {
              final XFile? x = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (x!= null) setD(() => tmpPhoto = x.path);
            }, child: Stack(children: [
              tmpPhoto.isNotEmpty && File(tmpPhoto).existsSync()? CircleAvatar(radius: 40, backgroundImage: FileImage(File(tmpPhoto))) : CircleAvatar(radius: 40, backgroundColor: Colors.orange[100], child: Text(c1.text.isEmpty? "?" : c1.text[0].toUpperCase(), style: const TextStyle(fontSize: 30))),
              Positioned(bottom: 0, right: 0, child: Container(decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle), padding: const EdgeInsets.all(6), child: const Icon(Icons.camera_alt, size: 16, color: Colors.white)))
            ])),
            const SizedBox(height: 8),
            const Text("Tap to add photo", style: TextStyle(fontSize: 10, color: Colors.grey)),
            TextField(controller: c1, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: c2, decoration: const InputDecoration(labelText: "Age"), keyboardType: TextInputType.number),
            TextField(controller: c3, decoration: const InputDecoration(labelText: "Std"), keyboardType: TextInputType.number),
            TextField(controller: c4, decoration: const InputDecoration(labelText: "Fee"), keyboardType: TextInputType.number),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(onPressed: () {
              if (c1.text.isEmpty) return;
              setState(() {
                Student ns = Student(c1.text, int.tryParse(c2.text)?? 6, int.tryParse(c3.text)?? 6, int.tryParse(c4.text)?? 1000, old?.paid?? [1], photo: tmpPhoto.isEmpty? null : tmpPhoto);
                if (old == null) all.add(ns); else all[idx!] = ns;
              });
              save(); Navigator.pop(context);
            }, child: Text(old == null? "Add" : "Update"))
          ],
        );
      });
    });
  }

  void deleteStu(int i) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text("Delete?"),
      content: Text("${all[i].name} delete?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () { setState(() => all.removeAt(i)); save(); Navigator.pop(context); }, child: const Text("Yes", style: TextStyle(color: Colors.white)))
      ]
    ));
  }  Future<void> receipt(Student s, int mi) async {
    String no = "SK-${Random().nextInt(9000)+1000}";
    final rec = ui.PictureRecorder();
    final can = Canvas(rec);
    const double W = 700, H = 900;
    can.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0,0,W,H), const Radius.circular(20)), Paint()..color = Colors.white);
    can.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0,0,W,H), const Radius.circular(20)), Paint()..color = Colors.orange..style = PaintingStyle.stroke..strokeWidth = 8);
    ui.Image? stuImg;
    try {
      if (s.photo!= null && File(s.photo!).existsSync()) {
        final b = await File(s.photo!).readAsBytes();
        final co = await ui.instantiateImageCodec(b, targetWidth: 200);
        final f = await co.getNextFrame();
        stuImg = f.image;
      }
    } catch (e) {}
    try {
      ui.Image logo;
      if (logoPath!= null && File(logoPath!).existsSync()) {
        final b = await File(logoPath!).readAsBytes();
        final co = await ui.instantiateImageCodec(b);
        final f = await co.getNextFrame(); logo = f.image;
      } else {
        final bd = await rootBundle.load('assets/logo.png');
        final co = await ui.instantiateImageCodec(bd.buffer.asUint8List());
        final f = await co.getNextFrame(); logo = f.image;
      }
      can.drawImageRect(logo, Rect.fromLTWH(0,0,logo.width.toDouble(), logo.height.toDouble()), const Rect.fromLTWH(30,25,90,90), Paint());
    } catch (e) {}
    if (stuImg!= null) {
      can.drawImageRect(stuImg, Rect.fromLTWH(0,0,stuImg.width.toDouble(), stuImg.height.toDouble()), const Rect.fromLTWH(560,200,110,110), Paint());
    }
    void txt(String t, double x, double y, double sz, Color c, {bool b = false}) {
      final tp = TextPainter(text: TextSpan(text: t, style: TextStyle(color: c, fontSize: sz, fontWeight: b? FontWeight.bold : FontWeight.normal)), textDirection: TextDirection.ltr);
      tp.layout(); tp.paint(can, Offset(x,y));
    }
    txt(className, 140, 30, 28, Colors.black, b: true);
    txt("$profName | $address | $phone", 140, 70, 16, Colors.red);
    txt("FEE RECEIPT", 250, 145, 28, const Color(0xFF2E7D32), b: true);
    txt("No: #$no", 30, 200, 18, Colors.black, b: true);
    txt("Date: 05/10/2026", 30, 230, 18, Colors.black);
    txt("Student: ${s.name}", 30, 280, 22, Colors.black, b: true);
    txt("Std: ${s.std} | Age: ${s.age}", 30, 315, 18, Colors.black);
    txt("Month: ${mN[mi]}", 30, 360, 20, const Color(0xFF2E7D32), b: true);
    txt("Amount: Rs ${s.fee} PAID", 30, 395, 24, const Color(0xFF2E7D32), b: true);
    final pic = rec.endRecording();
    final im = await pic.toImage(W.toInt(), H.toInt());
    final bd = await im.toByteData(format: ui.ImageByteFormat.png);
    final bytes = bd!.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/Receipt_${s.name}_$no.png");
    await file.writeAsBytes(bytes);
    if (!mounted) return;
    showDialog(context: context, builder: (_) => Dialog(child: Column(mainAxisSize: MainAxisSize.min, children: [Image.memory(bytes, height: 400), Row(children: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")), ElevatedButton(onPressed: () async { await Share.shareXFiles([XFile(file.path)]); }, child: const Text("Share"))])])));
  }

  @override Widget build(BuildContext context) {
    List<Student> f = all.where((s) => s.name.toLowerCase().contains(search.toLowerCase())).toList();
    if (filter == "Due") f = f.where((s) => s.paid.length < 12).toList();
    return Scaffold(
      appBar: AppBar(title: Text(className), actions: [
        IconButton(icon: const Icon(Icons.backup), onPressed: backupExport),
        IconButton(icon: const Icon(Icons.restore), onPressed: backupImport),
      ]),
      floatingActionButton: FloatingActionButton(onPressed: () => studentDialog(), child: const Icon(Icons.add)),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: TextField(onChanged: (v) => setState(() => search = v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: "Search..."))),
        Expanded(child: ListView.builder(itemCount: f.length, itemBuilder: (c,i){
          var s = f[i];
          return GestureDetector(
            onLongPress: (){
              showModalBottomSheet(context: context, builder: (_)=> Column(mainAxisSize: MainAxisSize.min, children: [
                ListTile(leading: avatar(s, 20), title: Text(s.name)),
                ListTile(leading: const Icon(Icons.edit), title: const Text("Edit"), onTap: (){ Navigator.pop(context); studentDialog(old: s, idx: all.indexOf(s)); }),
                ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text("Delete"), onTap: (){ Navigator.pop(context); deleteStu(all.indexOf(s)); }),
              ]));
            },
            child: Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: ListTile(
              leading: avatar(s, 24),
              title: Text("${s.name} | Std ${s.std}"),
              subtitle: Text("Paid: ${s.paid.length} months"),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text("Rs ${s.fee}"),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.receipt), onPressed: ()=> receipt(s, DateTime.now().month-1)),
              ]),
            )),
          );
        }))
      ]),
    );
  }
}
