import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';

void main() => runApp(MaterialApp(home: SaiKrupaFinal(), debugShowCheckedModeBanner: false));

class Student {
  String name; int age; int fee; int std; List<int> paid; // 1-12 months
  Student(this.name, this.age, this.fee, this.std, this.paid);
}

class SaiKrupaFinal extends StatefulWidget { @override _State createState() => _State(); }

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
    Student("Samskurti", 14, 1200, 14, [1,2,3,4,5,6,7,8,9,10]),
    Student("Swaransh", 10, 1000, 10, [1,2,3]),
  ];
  String filter = "सर्व"; String search = "";
  List<String> mL = ["J","F","M","A","M","J","J","A","S","O","N","D"];
  List<String> mN = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];

  void receipt(Student s, int monthIdx){
    String no = "#SK-${Random().nextInt(9000)+1000}";
    String text = """*SAIKRUPA CLASSES*
प्रा. प्रदीप चव्हाण | Karad
Ph: 9822001122

*FEE RECEIPT*
Receipt: $no
Date: 5/10/2026
Student: ${s.name} (इ ${s.std})
Month: ${mN[monthIdx]} 2025
Amount: Rs ${s.fee}/- PAID

Fee Received, Thank you!
- SaiKrupa Classes""";

    showDialog(context: context, builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.orange, width: 2)),
      child: Padding(padding: EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [CircleAvatar(child: Text("SK")), SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("SAIKRUPA CLASSES", style: TextStyle(fontWeight: FontWeight.bold)), Text("Prof. Pradip Chavan", style: TextStyle(color: Colors.red, fontSize: 12)), Text("Karad | Ph: 9822001122", style: TextStyle(fontSize: 10))])]),
        Divider(color: Colors.orange, thickness: 2),
        Center(child: Text("FEE RECEIPT", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
        SizedBox(height: 10),
        Text("Receipt: $no", style: TextStyle(fontWeight: FontWeight.bold)),
        Text("Date: 5/10/2026"),
        Text("Student: ${s.name}"),
        Text("Month: ${mN[monthIdx]} 2025", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        Text("Amount: Rs ${s.fee}/- PAID", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Container(width: double.infinity, padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Color(0xFFE8F8E8), borderRadius: BorderRadius.circular(10)), child: Text("Fee Received, Thank you!", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
        SizedBox(height: 15),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: ()=>Navigator.pop(context), child: Text("Close"))),
          SizedBox(width: 10),
          Expanded(child: ElevatedButton.icon(icon: Icon(Icons.send), label: Text("WhatsApp"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, shape: StadiumBorder()), onPressed: (){ Share.share(text); })),
        ])
      ])),
    ));
  }

  @override
  Widget build(BuildContext context) {
    List<Student> filtered = all.where((s){
      bool matchSearch = s.name.toLowerCase().contains(search.toLowerCase());
      if(filter=="बाकी") return matchSearch && s.paid.length < 12;
      if(filter=="संपलेला") return matchSearch && s.paid.length == 12;
      return matchSearch;
    }).toList();
    int totalPaid = all.fold(0, (sum, s) => sum + (s.fee * s.paid.length));
    int totalBal = all.fold(0, (sum, s) => sum + (s.fee * (12 - s.paid.length)));
    int remaining = all.where((s)=> s.paid.length < 12).length;

    return Scaffold(
      backgroundColor: Color(0xFFFDF6F9),
      appBar: AppBar(title: Row(children: [CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.school, color: Colors.white, size: 18)), SizedBox(width: 8), Text("SAIKRUPA CLASSES", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))]), actions: [IconButton(icon: CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.add, color: Colors.white)), onPressed: (){}), IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: (){})], backgroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(child: Column(children: [
        // TOP GRADIENT DASHBOARD
        Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.orange, Colors.pinkAccent], begin: Alignment.centerLeft, end: Alignment.centerRight)), child: Column(children: [
          Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(children: [
            Text("सर्टेंब २०२५ (Sep 2025)", style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            CircleAvatar(radius: 25, child: Icon(Icons.person, size: 30)),
            SizedBox(height: 6),
            Text("SAIKRUPA CLASSES", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("प्रा. प्रदीप चव्हाण", style: TextStyle(fontSize: 12)),
            Text("सेक्रेट (Edit Profile)", style: TextStyle(fontSize: 10, color: Colors.blue)),
            SizedBox(height: 8),
            ElevatedButton(onPressed: (){}, child: Text("+ नवीन विद्यार्थी", style: TextStyle(fontSize: 12)), style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade100, foregroundColor: Colors.green)),
            SizedBox(height: 6),
            Row(children: [Icon(Icons.location_on, size: 14), Text(" कराड, महाराष्ट्र • 9822001122", style: TextStyle(fontSize: 11))])
          ])),
          SizedBox(height: 12),
          Row(children: [
            Expanded(child: Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("एकूण विद्यार्थी\n12\n12 इयत्ता + 4 इयत्ता 9", style: TextStyle(fontSize: 11)),]))),
            SizedBox(width: 8),
            Expanded(child: Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(12)), child: Column(children: [Text("एकूण जमा (PAID)", style: TextStyle(fontSize: 11)), Text("₹${totalPaid},", style: TextStyle(fontWeight: FontWeight.bold)), Text("₹34,100", style: TextStyle(fontWeight: FontWeight.bold))]))),
          ]),
          SizedBox(height: 8),
          Row(children: [
            Expanded(child: Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(12)), child: Column(children: [Text("एकूण राहिलेले (BALANCE)", style: TextStyle(fontSize: 11)), Text("₹${totalBal}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))]))),
            SizedBox(width: 8),
            Expanded(child: Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(12)), child: Column(children: [Text("बाकी असलेली\n12 विद्यार्थी\nWhatsApp पाठवा", style: TextStyle(fontSize: 11)), ElevatedButton(onPressed: (){}, child: Text("WhatsApp पाठवा", style: TextStyle(fontSize: 10)), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: Size(100, 28)))]))),
          ])
        ])),
        Padding(padding: EdgeInsets.all(12), child: TextField(onChanged: (v)=> setState(()=> search=v), decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: "विद्यार्थी शोधा (Search by name, roll no,...)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white))),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          FilterChip(label: Text("सर्व (${all.length})"), selected: filter=="सर्व", onSelected: (_)=> setState(()=> filter="सर्व")),
          FilterChip(label: Text("बाकी ($remaining)"), selected: filter=="बाकी", onSelected: (_)=> setState(()=> filter="बाकी")),
          FilterChip(label: Text("संपलेला (${all.length-remaining})"), selected: filter=="संपलेला", onSelected: (_)=> setState(()=> filter="संपलेला")),
        ]),
       ...List.generate(filtered.length, (i){
          var s = filtered[i]; int paidAmt = s.fee * s.paid.length; int bal = s.fee * (12 - s.paid.length);
          return Card(margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(padding: EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("${i+1} ${s.name} | इ ${s.std} (Age ${s.age})", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)), child: Text("Fee Price\n₹${s.fee}", textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))) ]),
            Text("नोंदणी: 1 - इ - / Sep 2025", style: TextStyle(fontSize: 10, color: Colors.grey)),
            SizedBox(height: 8),
            GridView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, childAspectRatio: 1.6, crossAxisSpacing: 5, mainAxisSpacing: 5), itemCount: 12, itemBuilder: (c,m){
              bool isPaid = s.paid.contains(m+1);
              return InkWell(onTap: ()=> receipt(s, m), child: Container(decoration: BoxDecoration(color: isPaid? Color(0xFF4CAF50) : Color(0xFFFFCDD2), borderRadius: BorderRadius.circular(6), border: Border.all(color: isPaid? Colors.green.shade700 : Colors.red.shade200)), child: Center(child: Text(mL[m], style: TextStyle(color: isPaid? Colors.white : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)))));
            }),
            SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("जमा (Paid)\n₹$paidAmt", style: TextStyle(fontSize: 11)), Text("बाकी (Balance)\n₹$bal", style: TextStyle(fontSize: 11, color: Colors.red)),
              Row(children: [
                ElevatedButton(onPressed: ()=> receipt(s, DateTime.now().month-1), child: Text("पावती", style: TextStyle(fontSize: 10)), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, minimumSize: Size(45,28), padding: EdgeInsets.zero)),
                SizedBox(width: 4),
                ElevatedButton(onPressed: (){}, child: Text("एडिट", style: TextStyle(fontSize: 10)), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, minimumSize: Size(45,28), padding: EdgeInsets.zero)),
                SizedBox(width: 4),
                ElevatedButton(onPressed: ()=> receipt(s, DateTime.now().month-1), child: Text("WhatsApp", style: TextStyle(fontSize: 10)), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: Size(60,28), padding: EdgeInsets.zero)),
              ])
            ])
          ]))),
        })
      ])),
    );
  }
}
