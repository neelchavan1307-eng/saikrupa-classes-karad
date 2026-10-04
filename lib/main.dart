import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';

void main() => runApp(const MaterialApp(home: SaiKrupaFinal(), debugShowCheckedModeBanner: false));

class Student {
  String name; int age; int fee; int std; List<int> paid;
  Student(this.name, this.age, this.fee, this.std, this.paid);
}

class SaiKrupaFinal extends StatefulWidget {
  const SaiKrupaFinal({super.key});
  @override
  State<SaiKrupaFinal> createState() => _State();
}

class _State extends State<SaiKrupaFinal> {
  List<Student> all = [
    Student("Vihan Tupe", 6, 1000, 6, [1,2,3,4,5,6,7,8]),
    Student("Krisha Kirme", 10, 1200, 10, [1,2,3,4,5,6,7]),
    Student("Anshuman Itape", 10, 1000, 10, [1,2,3,4,5,6,7]),
    Student("Aaradhya Yadav", 8, 1000, 8, [1,2,3,4]),
    Student("Samyak Shirse", 8, 1000, 8, [1,2,3,4]),
    Student("Shreya Gadkar", 11, 1000, 11, [1,2,3,4,5,6]),
    Student("Swara Patil", 3, 800, 3, [1]),
    Student("Swaroop Patil", 3, 650, 3, [1,2,3,4]),
    Student("Tejal Patil", 25, 1500, 25, [1,2,3,4,5,6,7,8,9,10]),
    Student("Poorva Patil", 20, 1500, 20, [1,2,3,4,5,6,7,8,9,10]),
    Student("Swaransh", 10, 1000, 10, [1,2,3,4,5,6,7,8,9,10]),
    Student("pradip chavan", 5, 500, 5, [1,2,3,4,5,6,7,8,9,10,11,12]),
  ];
  String filter = "सर्व"; String search = "";
  List<String> mL = ["J","F","M","A","M","J","J","A","S","O","N","D"];
  List<String> mN = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];

  void receipt(Student s, int monthIdx){
    String no = "SK-${Random().nextInt(9000)+1000}";
    String text = "*SAIKRUPA CLASSES*\nProf. Pradip Chavan | Karad\nPh: 9822001122\n-------------------\n*FEE RECEIPT*\nReceipt: $no\nDate: 5/10/2026\nStudent: ${s.name}\nMonth: ${mN[monthIdx]} 2025\nAmount: Rs ${s.fee}/- PAID\n\nFee Received, Thank you!";
    showDialog(context: context, builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.orange, width: 2)),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Image.asset('assets/logo.png', width: 55, height: 55, errorBuilder: (c,e,s)=> const CircleAvatar(child: Text("SK"))),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text("SAIKRUPA CLASSES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text("Prof. Pradip Chavan", style: TextStyle(color: Colors.red, fontSize: 12)),
            Text("Karad", style: TextStyle(fontSize: 11)),
            Text("Ph: 9822001122", style: TextStyle(fontSize: 10)),
          ])
        ]),
        const Divider(color: Colors.orange, thickness: 1.5),
        const Center(child: Text("FEE RECEIPT", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16))),
        const Divider(),
        const SizedBox(height: 5),
        Text("Receipt: #$no", style: const TextStyle(fontWeight: FontWeight.bold)),
        Text("Date: 5/10/2026"),
        Text("Student: ${s.name}", style: const TextStyle(fontWeight: FontWeight.bold)),
        Text("Month: ${mN[monthIdx]} 2025", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        Text("Amount: Rs ${s.fee}/- PAID", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFE8F8E8), borderRadius: BorderRadius.circular(8)), child: const Text("Fee Received, Thank you!", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(height: 15),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: ()=>Navigator.pop(context), style: OutlinedButton.styleFrom(shape: const StadiumBorder()), child: const Text("Close"))),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.send, size: 18), label: const Text("WhatsApp"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, shape: const StadiumBorder()), onPressed: (){ Share.share(text); })),
        ])
      ])),
    ));
  }

  @override
  Widget build(BuildContext context) {
    List<Student> filtered = all.where((s){
      bool match = s.name.toLowerCase().contains(search.toLowerCase());
      if(filter=="बाकी") return match && s.paid.length < 12;
      if(filter=="संपलेला") return match && s.paid.length == 12;
      return match;
    }).toList();
    int totalPaid = all.fold(0, (sum, s) => sum + (s.fee * s.paid.length));
    int totalBal = all.fold(0, (sum, s) => sum + (s.fee * (12 - s.paid.length)));
    int remaining = all.where((s)=> s.paid.length < 12).length;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      appBar: AppBar(title: Row(children: [Image.asset('assets/logo.png', width: 32, height: 32, errorBuilder: (c,e,s)=> const Icon(Icons.school)), const SizedBox(width: 8), const Text("SAIKRUPA CLASSES", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))]), backgroundColor: Colors.white),
      body: SingleChildScrollView(child: Column(children: [
        Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.orange, Colors.pinkAccent])), child: Row(children: [
          Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(12)), child: Text("एकूण जमा\n₹$totalPaid", style: const TextStyle(fontWeight: FontWeight.bold)))),
          const SizedBox(width: 8),
          Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(12)), child: Text("बाकी\n₹$totalBal", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)))),
        ])),
        Padding(padding: const EdgeInsets.all(12), child: TextField(onChanged: (v)=> setState(()=> search=v), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: "विद्यार्थी शोधा", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white))),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          FilterChip(label: Text("सर्व (${all.length})"), selected: filter=="सर्व", onSelected: (_)=> setState(()=> filter="सर्व")),
          FilterChip(label: Text("बाकी ($remaining)"), selected: filter=="बाकी", onSelected: (_)=> setState(()=> filter="बाकी")),
          FilterChip(label: Text("संपलेला"), selected: filter=="संपलेला", onSelected: (_)=> setState(()=> filter="संपलेला")),
        ]),
      ...List.generate(filtered.length, (i){
          var s = filtered[i]; int paidAmt = s.fee * s.paid.length; int bal = s.fee * (12 - s.paid.length);
          return Card(margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("${i+1} ${s.name} | इ ${s.std} Age ${s.age}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), Text("Rs ${s.fee}", style: const TextStyle(fontWeight: FontWeight.bold))]),
            const SizedBox(height: 8),
            GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, childAspectRatio: 1.6, crossAxisSpacing: 5, mainAxisSpacing: 5), itemCount: 12, itemBuilder: (c,m){
              bool isPaid = s.paid.contains(m+1);
              return InkWell(onTap: ()=> receipt(s, m), child: Container(decoration: BoxDecoration(color: isPaid? const Color(0xFF4CAF50) : const Color(0xFFFFCDD2), borderRadius: BorderRadius.circular(6)), child: Center(child: Text(mL[m], style: TextStyle(color: isPaid? Colors.white : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)))));
            }),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Paid Rs $paidAmt", style: const TextStyle(fontSize: 11)), Text("Bal Rs $bal", style: const TextStyle(fontSize: 11, color: Colors.red)),
              Row(children: [
                ElevatedButton(onPressed: ()=> receipt(s, DateTime.now().month-1), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, minimumSize: const Size(50,28)), child: const Text("Receipt", style: TextStyle(fontSize: 9))),
                const SizedBox(width: 4),
                ElevatedButton(onPressed: ()=> receipt(s, DateTime.now().month-1), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: const Size(45,28)), child: const Text("WA", style: TextStyle(fontSize: 9))),
              ])
            ])
          ]))),
        })
      ])),
    );
  }
}
