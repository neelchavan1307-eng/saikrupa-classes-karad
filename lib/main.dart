import 'package:flutter/material.dart';

void main() => runApp(const SaikrupaApp());

class SaikrupaApp extends StatelessWidget {
  const SaikrupaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // --- Tujha Saikrupa_Backup.json madhun load kelela data ---
  final List<Map> backupRaw = [
    {"n":"Vihan Tupe","a":9,"s":3,"f":600,"p":[7,8,9,1],"ph":null},
    {"n":"Krisha Kirme","a":10,"s":10,"f":1200,"p":[7,8,1],"ph":null},
    {"n":"Anshuman ","a":6,"s":3,"f":600,"p":[9,7,8],"ph":null},
    {"n":"samayak","a":6,"s":1,"f":500,"p":[7,8,9],"ph":null},
    {"n":"Aradhya ","a":6,"s":4,"f":700,"p":[8,9],"ph":null},
    {"n":"shreya","a":6,"s":2,"f":500,"p":[8],"ph":null},
    {"n":"Aravi","a":6,"s":1,"f":500,"p":[8],"ph":null},
    {"n":"Swarangi swarup","a":6,"s":6,"f":700,"p":[7],"ph":null},
    {"n":"swaransh ","a":6,"s":1,"f":500,"p":[7,8,9],"ph":null},
    {"n":"Tejal","a":6,"s":5,"f":400,"p":[],"ph":null},
    {"n":"Poorva ","a":6,"s":5,"f":200,"p":[8],"ph":null},
    {"n":"Sanskruti ","a":6,"s":6,"f":850,"p":[9],"ph":null},
    {"n":"piyush","a":6,"s":3,"f":600,"p":[],"ph":null}
  ];

  late List<Map<String, dynamic>> students;
  String filter = "Sarv";
  String search = "";

  @override
  void initState() {
    super.initState();
    // Backup la aplya navin format madhe convert
    students = backupRaw.map((b) {
      List<int> months12 = List.filled(12, 0);
      for (var m in b['p']) {
        if (m >= 1 && m <= 12) months12[m-1] = 1;
      }
      return {
        "name": (b['n'] as String).trim(),
        "age": b['a'].toString(),
        "std": b['s'].toString(),
        "fee": b['f'],
        "address": "Karad",
        "mobile": b['ph']?.toString() ?? "",
        "months": months12,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var filtered = students.where((s) {
      if (search.isNotEmpty && !s['name'].toLowerCase().contains(search.toLowerCase())) return false;
      bool hasBalance = s['months'].contains(0);
      if (filter == "Baki" && !hasBalance) return false;
      if (filter == "Jama" && hasBalance) return false;
      return true;
    }).toList();

    int totalPaid = students.fold(0, (sum, s) => sum + (s['months'] as List<int>).where((m)=>m==1).length * (s['fee'] as int));
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1E6),
      body: SafeArea(
        child: Column(children: [
          // 3D HEADER WITH LOGO
          Container(
            height: 125, margin: const EdgeInsets.all(14), padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white, width: 2), boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.25), blurRadius: 22, offset: const Offset(0, 10))]),
            child: Row(children: [
              ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset('assets/logo.png', width: 88, height: 88, fit: BoxFit.cover, errorBuilder: (_,__,___)=> const Icon(Icons.school, size: 50, color: Colors.orange))),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("॥ श्री साईनाथाय नमः ॥", style: TextStyle(fontSize: 9, color: Colors.brown, fontWeight: FontWeight.bold)),
                Text("SAIKRUPA\nCLASSES", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, height: 1, color: Color(0xFF1E3A8A))),
                Text("FAITH • DEVOTION • EDUCATION", style: TextStyle(fontSize: 7)),
              ]))
            ]),
          ),
          // STATS
          Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Row(children: [
            _stat("${students.length}", "Vidyarthi"), _stat("₹$totalPaid", "Jama"), _stat("₹${students.length*12*600 - totalPaid}", "Baki"),
          ])),
          const SizedBox(height: 12),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: TextField(onChanged: (v)=>setState(()=>search=v), decoration: InputDecoration(hintText: "Vihan, Krisha shodha...", prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)))),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Row(children: ["Sarv","Baki","Jama"].map((f) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(f), selected: filter==f, onSelected: (_)=>setState(()=>filter=f), selectedColor: Colors.orange.shade200))).toList())),
          const SizedBox(height: 8),
          Expanded(child: ListView.builder(padding: const EdgeInsets.all(14), itemCount: filtered.length, itemBuilder: (_, i) => _card(filtered[i]))),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: (){}, backgroundColor: Colors.orange, icon: const Icon(Icons.add, color: Colors.white), label: const Text("Navin", style: TextStyle(color: Colors.white))),
    );
  }

  Widget _stat(String v, String l) => Expanded(child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Column(children: [Text(v, style: const TextStyle(fontWeight: FontWeight.bold)), Text(l, style: const TextStyle(fontSize: 10))])));

  Widget _card(Map s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        onTap: () async {
          var updated = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditFull(student: s)));
          if (updated != null) setState(() { int idx = students.indexWhere((e)=>e['name']==s['name']); if(idx!=-1) students[idx]=updated; });
        },
        leading: CircleAvatar(backgroundColor: Colors.orange.shade100, child: Text(s['name'][0].toUpperCase(), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
        title: Text(s['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Vay: ${s['age']} • Std: ${s['std']} • Fee: ₹${s['fee']} • Mob: ${s['mobile'].isEmpty? 'No Number': s['mobile']}", style: const TextStyle(fontSize: 11)),
          const SizedBox(height: 5),
          Row(children: List.generate(12, (mi) {
            bool paid = s['months'][mi]==1;
            return Container(margin: const EdgeInsets.only(right: 2), width: 16, height: 16, decoration: BoxDecoration(color: paid? Colors.green: Colors.pink.shade100, borderRadius: BorderRadius.circular(4)), child: Center(child: Text(["J","F","M","A","M","J","J","A","S","O","N","D"][mi], style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: paid? Colors.white: Colors.black54))));
          }))
        ]),
        trailing: const Icon(Icons.edit, color: Colors.orange, size: 20),
      ),
    );
  }
}

// FULL SCREEN EDIT - OPTION 1
class EditFull extends StatefulWidget {
  final Map student; const EditFull({super.key, required this.student});
  @override State<EditFull> createState() => _EditFullState();
}
class _EditFullState extends State<EditFull> {
  late TextEditingController nameC, feeC, addressC, mobileC, ageC, stdC;
  late List<int> months;
  @override void initState() { super.initState(); nameC=TextEditingController(text: widget.student['name']); feeC=TextEditingController(text: widget.student['fee'].toString()); addressC=TextEditingController(text: widget.student['address']); mobileC=TextEditingController(text: widget.student['mobile']); ageC=TextEditingController(text: widget.student['age']); stdC=TextEditingController(text: widget.student['std']); months=List<int>.from(widget.student['months']); }
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1E6),
      appBar: AppBar(title: const Text("VIDYARTHI EDIT"), backgroundColor: Colors.white, elevation: 0, actions: [IconButton(onPressed: _save, icon: const Icon(Icons.check_circle, color: Colors.green, size: 32))]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(18), child: Column(children: [
        CircleAvatar(radius: 50, backgroundColor: Colors.orange.shade100, child: Text(widget.student['name'][0].toUpperCase(), style: const TextStyle(fontSize: 36, color: Colors.orange, fontWeight: FontWeight.bold))),
        const SizedBox(height: 16),
        _f("Nav", nameC, Icons.person), _f("Vay", ageC, Icons.cake), _f("Iyatta (Std)", stdC, Icons.school), _f("Fee ₹", feeC, Icons.currency_rupee), _f("Pata", addressC, Icons.home), _f("Mobile Number", mobileC, Icons.phone, type: TextInputType.phone),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Fee Mahine - Tap kara", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: List.generate(12, (i){ bool isPaid=months[i]==1; return GestureDetector(onTap: ()=>setState(()=> months[i]=isPaid?0:1), child: Container(width: 60, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isPaid? Colors.green: Colors.pink.shade100, borderRadius: BorderRadius.circular(12)), child: Column(children: [Text(["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"][i], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isPaid? Colors.white: Colors.black)), Icon(isPaid? Icons.check: Icons.close, size: 14, color: isPaid? Colors.white: Colors.pink)])));})),
        ])),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text("SAVE CHANGES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ])),
    );
  }
  Widget _f(String l, TextEditingController c, IconData ic, {TextInputType type = TextInputType.text}) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: c, keyboardType: type, decoration: InputDecoration(labelText: l, prefixIcon: Icon(ic, color: Colors.orange), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))));
  void _save(){ var u={"name":nameC.text, "age":ageC.text, "std":stdC.text, "fee":int.tryParse(feeC.text)??600, "address":addressC.text, "mobile":mobileC.text, "months":months}; Navigator.pop(context, u); }
}
