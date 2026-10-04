import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const MaterialApp(home: SaiKrupaFinal(), debugShowCheckedModeBanner: false));

class Student {
  String name; int age; int fee; List<int> paid;
  Student(this.name, this.age, this.fee, this.paid);
}

class SaiKrupaFinal extends StatefulWidget {
  const SaiKrupaFinal({super.key});
  @override
  State<SaiKrupaFinal> createState() => _State();
}

class _State extends State<SaiKrupaFinal> {
  List<Student> all = [
    Student("Vihan Tupe", 6, 1000, [1,2,3,4,5,6,7,8]),
    Student("Krisha Kirme", 10, 1200, [1,2,3,4,5,6,7]),
    Student("Anshuman Itape", 10, 1000, [1,2,3,4,5,6,7]),
    Student("Aaradhya Yadav", 8, 1000, [1,2,3,4]),
    Student("Samyak Shirke", 8, 1000, [1,2,3,4]),
    Student("Shreya Gadekar", 11, 1000, [1,2,3,4,5,6]),
    Student("Swara Patil", 3, 800, [1]),
    Student("Swaroop Patil", 3, 800, [1,2,3,4]),
    Student("Tejal Patil", 25, 1500, [1]),
    Student("Poorva Patil", 20, 1500, [1,2]),
    Student("Sanskurti", 14, 1200, [1,2,3]),
    Student("Swaransh", 10, 1000, [1,2,3]),
  ];
  String filter = "सर्व"; String search = "";
  List<String> mL = ["J","F","M","A","M","J","J","A","S","O","N","D"];
  List<String> mN = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];

  Future<void> generateAndShareReceipt(Student s, int mi) async {
    String no = "SK-${Random().nextInt(9000)+1000}";
    // 1. Create a picture recorder
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const width = 600.0;
    const height = 750.0;
    final paintWhite = Paint()..color = Colors.white;
    final paintOrange = Paint()..color = Colors.orange..style = PaintingStyle.stroke..strokeWidth = 6;

    // Background
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0,0,width,height), const Radius.circular(24)), paintWhite);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0,0,width,height), const Radius.circular(24)), paintOrange);

    // Draw Texts
    void drawText(String text, double x, double y, double size, Color color, {bool bold = false}) {
      final tp = TextPainter(text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size, fontWeight: bold? FontWeight.bold : FontWeight.normal)), textDirection: TextDirection.ltr);
      tp.layout(); tp.paint(canvas, Offset(x,y));
    }

    drawText("SAIKRUPA CLASSES", 30, 30, 28, Colors.black, bold: true);
    drawText("Prof. Pradip Chavan | Karad | Ph: 9822001122", 30, 70, 16, Colors.red);
    canvas.drawLine(const Offset(30,110), const Offset(width-30,110), Paint()..color=Colors.orange..strokeWidth=2);

    drawText("FEE RECEIPT", 200, 130, 26, Colors.green, bold: true);
    drawText("Receipt No: #$no", 30, 180, 18, Colors.black, bold: true);
    drawText("Date: 5/10/2026", 30, 210, 18, Colors.black);
    drawText("Student Name: ${s.name}", 30, 260, 20, Colors.black, bold: true);
    drawText("Standard: ${s.age}th | Age: ${s.age}", 30, 295, 18, Colors.black);
    drawText("Month: ${mN[mi]} 2025", 30, 340, 20, Colors.green, bold: true);
    drawText("Amount: Rs ${s.fee}/- PAID", 30, 375, 22, Colors.green, bold: true);

    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(30, 430, width-60, 80), const Radius.circular(12)), Paint()..color = const Color(0xFFE8F8E8));
    drawText("Fee Received, Thank you!", 160, 455, 20, Colors.green, bold: true);
    drawText("॥ श्री साईनाथाय नमः ॥", 200, 600, 16, Colors.orange, bold: true);

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/Receipt_${s.name}_$no.png");
    await file.writeAsBytes(pngBytes);

    // Show Dialog with Image Preview + Share
    if (!mounted) return;
    showDialog(context: context, builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.orange, width: 2)),
      child: Padding(padding: const EdgeInsets.all(12), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Image.memory(pngBytes, height: 350),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: ()=>Navigator.pop(context), child: const Text("Close"))),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.share), label: const Text("WhatsApp ला पाठवा"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), onPressed: () async {
            await Share.shareXFiles([XFile(file.path)], text: "*SAIKRUPA CLASSES* - Fee Receipt for ${s.name}");
          })),
        ])
      ])),
    ));
  }

  void toggleFee(Student s, int m){ setState((){ if(s.paid.contains(m)) s.paid.remove(m); else s.paid.add(m); }); }

  @override
  Widget build(BuildContext context) {
    List<Student> f = all.where((s)=> s.name.toLowerCase().contains(search.toLowerCase())).toList();
    int totalPaid = all.fold(0, (a,b)=> a + b.fee * b.paid.length);
    int totalBal = all.fold(0, (a,b)=> a + b.fee * (12 - b.paid.length));
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      appBar: AppBar(title: Row(children: [Image.asset("assets/logo.png", width: 30, height: 30), const SizedBox(width: 8), const Text("SAIKRUPA CLASSES", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))]), backgroundColor: Colors.white),
      body: SingleChildScrollView(child: Column(children: [
        Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.orange, Colors.pinkAccent])), child: Row(children: [
          Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(12)), child: Text("जमा\nRs $totalPaid", style: const TextStyle(fontWeight: FontWeight.bold)))),
          const SizedBox(width: 8),
          Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(12)), child: Text("बाकी\nRs $totalBal", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)))),
        ])),
        Padding(padding: const EdgeInsets.all(12), child: TextField(onChanged: (v)=> setState(()=> search=v), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: "शोधा", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white))),
      ...List.generate(f.length, (i){
          var s = f[i];
          return Card(margin: const EdgeInsets.all(8), child: Padding(padding: const EdgeInsets.all(10), child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("${s.name} | Age ${s.age}", style: const TextStyle(fontWeight: FontWeight.bold)), Text("Rs ${s.fee}")]),
            const SizedBox(height: 8),
            GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, childAspectRatio: 1.6, crossAxisSpacing: 4, mainAxisSpacing: 4), itemCount: 12, itemBuilder: (c,m){
              bool ok = s.paid.contains(m+1);
              return InkWell(onTap: ()=> toggleFee(s, m+1), child: Container(decoration: BoxDecoration(color: ok? Colors.green : const Color(0xFFFFCDD2), borderRadius: BorderRadius.circular(5)), child: Center(child: Text(mL[m], style: TextStyle(color: ok? Colors.white : Colors.red, fontWeight: FontWeight.bold)))));
            }),
            const SizedBox(height: 8),
            Row(children: [
              ElevatedButton(onPressed: ()=> generateAndShareReceipt(s, DateTime.now().month-1), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white), child: const Text("Digital पावती", style: TextStyle(fontSize: 10))),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: ()=> generateAndShareReceipt(s, DateTime.now().month-1), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), child: const Text("Image WhatsApp", style: TextStyle(fontSize: 10))),
            ])
          ])));
        })
      ])),
    );
  }
}
